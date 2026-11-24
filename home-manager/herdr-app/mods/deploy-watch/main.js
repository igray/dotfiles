/**
 * Watches the `production-ats` CodePipeline: the running (or last) execution's
 * stages, the ECS web/worker rollout while it deploys, and recent executions.
 *
 * Deploy state is read from AWS only, so it shows any deploy, not just ones
 * the spark-deploy skill drives. When one of Iain's own PRs starts deploying,
 * the mod reveals the `insights` column on its `deploy` tab and posts a
 * notification when that execution finishes.
 *
 * Props: `{ column?: string, stack?: string, tab?: string }` name the layout
 * nodes it reveals (defaults `insights`, `insights-tabs`, `deploy`).
 */

import { View, div } from "gpui-kit";
import { v_flex, h_flex, Scrollbar } from "gpui-base";
import { exec, home, theme, run, notify, props } from "herdr";

const PIPELINE = "production-ats";
const REGION = "us-east-1";
const ME = "igray";
const STAGES = ["Source", "Build", "DockerImageBuild", "RunMigrations", "Deploy", "Post-Deploy-Operations"];
const IDLE_MS = 90000;
const ACTIVE_MS = 20000;
const ATS = `${home()}/Work/cp/ats`;

// `aws` and its credentials exist only in the ats devenv, so every query runs in
// one `direnv exec` to pay the environment's startup once per refresh.
const SNAPSHOT = `
set -e
q() { aws "$@" --region ${REGION} --output json; }
ecs() { q ecs describe-services --cluster "$1" --services "$2" \
  --query 'services[0].deployments[?status==\`PRIMARY\`]|[0].{running:runningCount,desired:desiredCount,state:rolloutState}'; }
printf '{"list":'; q codepipeline list-pipeline-executions --pipeline-name ${PIPELINE} --max-items 6
printf ',"state":'; q codepipeline get-pipeline-state --name ${PIPELINE}
if [ "$1" = ecs ]; then
  printf ',"web":'; ecs production-ats-web production-web
  printf ',"worker":'; ecs production-ats-worker production-worker-daemon
fi
printf '}'
`;

async function snapshot(withEcs) {
  const r = await exec("direnv", ["exec", ATS, "sh", "-c", SNAPSHOT, "sh", withEcs ? "ecs" : ""], { timeout: 120000 });
  if (r.code !== 0) throw new Error(r.stderr.trim().split("\n").pop() || `aws exited ${r.code}`);
  return JSON.parse(r.stdout);
}

const consoleUrl = (id) =>
  `https://${REGION}.console.aws.amazon.com/codesuite/codepipeline/pipelines/${PIPELINE}/executions/${id}/timeline?region=${REGION}`;

function describe(summary) {
  const source = summary.sourceRevisions?.[0];
  let message = "";
  try { message = JSON.parse(source?.revisionSummary ?? "{}").CommitMessage ?? ""; } catch { message = source?.revisionSummary ?? ""; }
  const lines = message.split("\n").filter((l) => l.trim());
  const merge = /^Merge pull request #(\d+)/.exec(lines[0] ?? "");
  const squash = /\(#(\d+)\)\s*$/.exec(lines[0] ?? "");
  const number = Number(merge?.[1] ?? squash?.[1]) || null;
  const title = merge ? lines[1] ?? lines[0] : (lines[0] ?? "").replace(/\s*\(#\d+\)\s*$/, "");
  return {
    id: summary.pipelineExecutionId, status: summary.status, number, title,
    sha: source?.revisionId?.slice(0, 10) ?? "", started: summary.startTime ? new Date(summary.startTime) : null,
  };
}

function since(date) {
  if (!date) return "";
  const minutes = Math.max(0, Math.round((Date.now() - date.getTime()) / 60000));
  if (minutes < 60) return `${minutes}m ago`;
  const hours = Math.floor(minutes / 60);
  return hours < 24 ? `${hours}h ${minutes % 60}m ago` : date.toLocaleDateString();
}

export default class DeployWatch extends View {
  init(_props, cx) {
    this.recent = [];
    this.stages = [];
    this.authors = {};
    this.watching = new Set();
    this.revealed = new Set();
    this.first = true;
    this.tick(cx);
  }

  tick(cx) {
    this.refresh(cx);
    cx.timer.after(this.current?.status === "InProgress" ? ACTIVE_MS : IDLE_MS, (cx) => this.tick(cx));
  }

  refresh(cx) {
    if (this.loading) return;
    this.loading = true;
    cx.spawn(async (cx) => {
      try {
        const deploying = this.current?.status === "InProgress" && this.stages.some((s) => s.name === "Deploy" && s.status !== "Pending");
        const { list, state, web, worker } = await snapshot(deploying);
        this.recent = list.pipelineExecutionSummaries.map(describe);
        this.current = this.recent[0] ?? null;
        const byStage = Object.fromEntries(state.stageStates.map((s) => [s.stageName, s.latestExecution]));
        this.stages = STAGES.map((name) => {
          const latest = byStage[name];
          return { name, status: latest && latest.pipelineExecutionId === this.current?.id ? latest.status : "Pending" };
        });
        this.ecs = web || worker ? { web, worker } : null;
        await this.lookupAuthors(cx);
        this.react();
        this.error = null;
      } catch (e) {
        this.error = String(e.message ?? e);
      } finally {
        this.first = false;
        this.loading = false;
        cx.notify();
      }
    });
  }

  async lookupAuthors() {
    const missing = [...new Set(this.recent.map((d) => d.number).filter((n) => n && !(n in this.authors)))];
    await Promise.all(missing.map(async (number) => {
      const r = await exec("gh", ["pr", "view", String(number), "--repo", "CareerPlug/ats", "--json", "author", "-q", ".author.login"]);
      this.authors[number] = r.code === 0 ? r.stdout.trim() : null;
    }));
  }

  react() {
    for (const deploy of this.recent) {
      const mine = this.authors[deploy.number] === ME;
      if (deploy.status === "InProgress" && mine && !this.revealed.has(deploy.id)) {
        this.revealed.add(deploy.id);
        this.watching.add(deploy.id);
        if (!this.first) this.reveal();
      }
      if (deploy.status !== "InProgress" && this.watching.has(deploy.id)) {
        this.watching.delete(deploy.id);
        const ok = deploy.status === "Succeeded";
        notify({
          title: ok ? `Deployed #${deploy.number}` : `Deploy ${deploy.status.toLowerCase()}: #${deploy.number}`,
          body: deploy.title, level: ok ? "info" : "error",
        });
      }
    }
  }

  reveal() {
    const p = props() ?? {};
    run("layout.show", { id: p.column ?? "insights" });
    run("layout.select", { stack: p.stack ?? "insights-tabs", child: p.tab ?? "deploy" });
  }

  statusColor(status, t) {
    return { Succeeded: t.ansi2, InProgress: t.working, Failed: t.ansi1, Stopped: t.ansi1, Stopping: t.blocked, Superseded: t.dim, Cancelled: t.dim }[status] ?? t.dim;
  }

  stageRow(stage, t) {
    const glyph = { Succeeded: "✓", InProgress: "●", Failed: "✕", Stopped: "✕" }[stage.status] ?? "○";
    return h_flex().flex_none().gap(8).items_center().px(4).h(22)
      .child(div().w(14).flex_none().text_color(this.statusColor(stage.status, t)).child(glyph)
        .when(stage.status === "InProgress", (e) => e.loop("opacity", { from: 0.35, to: 1, period: 1200 })))
      .child(div().flex_1().min_w(0).truncate().text_color(stage.status === "Pending" ? t.dim : t.foreground).child(stage.name));
  }

  rolloutLine(label, part, t) {
    if (!part) return null;
    const counts = part.desired != null ? ` ${part.running}/${part.desired}` : "";
    return h_flex().px(4).gap(6).text_size(11)
      .child(div().w(52).text_color(t.muted).child(label))
      .child(div().text_color(part.state === "COMPLETED" ? t.ansi2 : part.state === "FAILED" ? t.ansi1 : t.working)
        .child(`${(part.state ?? "").toLowerCase().replace("_", " ")}${counts}`));
  }

  prLink(deploy, t) {
    return div().id(`deploy-pr-${deploy.id}`).flex_none().text_color(t.accent).cursor_pointer()
      .hover((s) => s.text_color(t.foreground))
      .on_click((_e, cx) => { cx.stop_propagation(); exec("xdg-open", [`https://github.com/CareerPlug/ats/pull/${deploy.number}`]).catch(() => null); })
      .child(deploy.number ? `#${deploy.number}` : deploy.sha);
  }

  currentCard(t) {
    const d = this.current;
    if (!d) return div().p(12).text_color(t.dim).child(this.first ? "Loading…" : "No executions");
    const author = this.authors[d.number];
    return v_flex().flex_none().m(8).p(10).gap(6).rounded(8).border_1().border_color(t.border).bg(t.surface)
      .child(h_flex().gap(8).items_center()
        .child(div().px(6).py(1).rounded(4).text_size(11).text_color(t.background).bg(this.statusColor(d.status, t)).child(d.status))
        .child(this.prLink(d, t))
        .child(div().flex_1())
        .child(div().id("deploy-console").text_size(11).text_color(t.muted).cursor_pointer().hover((s) => s.text_color(t.foreground))
          .on_click(() => exec("xdg-open", [consoleUrl(d.id)]).catch(() => null)).child("pipeline ↗")))
      .child(div().text_size(12).child(d.title || d.sha))
      .child(div().text_size(11).text_color(t.dim).child([author === ME ? "you" : author, since(d.started)].filter(Boolean).join(" · ")))
      .child(v_flex().pt(4).children(this.stages.map((s) => this.stageRow(s, t))))
      .when(Boolean(this.ecs), (e) => e.child(v_flex().pt(4).gap(2)
        .child(this.rolloutLine("web", this.ecs.web, t))
        .child(this.rolloutLine("worker", this.ecs.worker, t))));
  }

  render(_cx) {
    const t = theme();
    return v_flex().id("deploy-watch").size_full().min_h(0).bg(t.background).text_color(t.foreground).text_size(13)
      .child(h_flex().h(36).flex_none().px(12).gap(8).items_center().border_b(1).border_color(t.border)
        .child(div().font_semibold().child("Deploy"))
        .child(div().text_size(11).text_color(t.dim).child(PIPELINE))
        .child(div().flex_1())
        .child(div().id("deploy-refresh").px(6).py(2).rounded(5).text_size(11).text_color(t.muted).cursor_pointer()
          .hover((s) => s.bg(t.hover)).on_click((_e, cx) => this.refresh(cx)).child(this.loading ? "…" : "↻")))
      .when(Boolean(this.error), (e) => e.child(div().px(12).py(6).text_size(11).text_color(t.ansi1).child(this.error)))
      .child(div().flex_1().min_h(0).relative()
        .child(v_flex().id("deploy-list").absolute().inset_0().overflow_y_scroll()
          .child(this.currentCard(t))
          .child(div().px(12).pt(6).pb(2).text_size(11).font_semibold().text_color(t.muted).child("Recent"))
          .children(this.recent.slice(1).map((d) => h_flex().id(`deploy-${d.id}`).flex_none().mx(6).px(6).py(4).gap(8).items_center().rounded(6)
            .cursor_pointer().hover((s) => s.bg(t.hover)).on_click(() => exec("xdg-open", [consoleUrl(d.id)]).catch(() => null))
            .child(div().w(7).h(7).flex_none().rounded(4).bg(this.statusColor(d.status, t)))
            .child(this.prLink(d, t))
            .child(div().flex_1().min_w(0).truncate().child(d.title || d.sha))
            .child(div().flex_none().text_size(11).text_color(t.dim).child(since(d.started))))))
        .child(Scrollbar.vertical("deploy-list").absolute().inset_0()));
  }
}
