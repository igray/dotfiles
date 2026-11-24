/**
 * Review queue for CareerPlug/ats: PRs waiting on Iain's review, and his own
 * open PRs with their review state. A live version of the `find-review-prs`
 * and `find-reviewed-prs` skills.
 *
 * Rows open the PR in the browser. The row whose head branch is the focused
 * pane's branch is highlighted. Refreshes every three minutes; the header's
 * refresh button fetches at once.
 */

import { View, div } from "gpui-kit";
import { v_flex, h_flex, Scrollbar } from "gpui-base";
import { spaces, panes, focused, exec, theme } from "herdr";

const REPO = "CareerPlug/ats";
const ME = "igray";
const REVIEWERS_TEAM = "CareerPlug/reviewers";
const RESPONDED_LABEL = "Ready to Merge";
const SQUAD = { americac: "America", ryanarakawa: "Ryan", "dpowers-careerplug": "Domenick" };
const STALE_DAYS = 30;
const REFRESH_MS = 180000;
const GROUPS = ["Requested from you", "Your squad", "Everyone else"];

const MINE_QUERY = `
query($q: String!) {
  search(query: $q, type: ISSUE, first: 100) {
    nodes {
      ... on PullRequest {
        number title url isDraft baseRefName headRefName reviewDecision
        latestReviews(first: 30) { nodes { state submittedAt author { __typename login } } }
        reviews(last: 100) { nodes { body submittedAt author { __typename login } } }
        comments(last: 100) { nodes { createdAt author { login } } }
        reviewThreads(first: 100) { nodes { isResolved } }
        commits(last: 1) { nodes { commit { statusCheckRollup { state } } } }
      }
    }
  }
}`;

function focusedBranch() {
  const f = focused();
  const pane = f?.pane ? panes().find((p) => p.pane === f.pane) : null;
  return pane?.branch ?? spaces().find((s) => s.active)?.branch ?? null;
}

function rollupCi(checks) {
  const states = (checks ?? []).map((c) => c.conclusion || c.state || c.status).filter(Boolean);
  if (states.some((s) => ["FAILURE", "ERROR", "TIMED_OUT", "CANCELLED", "ACTION_REQUIRED"].includes(s))) return "failing";
  if (states.some((s) => ["PENDING", "QUEUED", "IN_PROGRESS", "EXPECTED", "WAITING"].includes(s))) return "pending";
  return states.length ? "green" : "none";
}

const STATE_CI = { SUCCESS: "green", PENDING: "pending", EXPECTED: "pending", FAILURE: "failing", ERROR: "failing" };

function incoming(prs) {
  const cutoff = Date.now() - STALE_DAYS * 86400000;
  const rows = prs
    .filter((pr) => pr.author.login !== ME && pr.reviewDecision !== "APPROVED" && Date.parse(pr.updatedAt) > cutoff)
    .map((pr) => ({
      ...pr,
      requestsMe: pr.reviewRequests.some((r) => r.login === ME),
      requestsTeam: pr.reviewRequests.some((r) => r.slug === REVIEWERS_TEAM),
    }))
    .filter((pr) => pr.requestsMe || pr.requestsTeam)
    .sort((a, b) => a.createdAt.localeCompare(b.createdAt))
    .map((pr) => ({
      number: pr.number, title: pr.title, url: pr.url, branch: pr.headRefName, ci: rollupCi(pr.statusCheckRollup),
      group: pr.requestsMe ? "Requested from you" : SQUAD[pr.author.login] ? "Your squad" : "Everyone else",
      detail: [
        SQUAD[pr.author.login] || pr.author.name || pr.author.login,
        `+${pr.additions}/−${pr.deletions}`,
        pr.baseRefName !== "main" ? `on ${pr.baseRefName}` : null,
      ].filter(Boolean).join(" · "),
    }));
  return GROUPS.map((group) => [group, rows.filter((r) => r.group === group)]);
}

function mine(nodes) {
  return nodes.map((pr) => {
    const human = pr.latestReviews.nodes.filter((r) => r.author && r.author.__typename !== "Bot" && r.author.login !== ME);
    const answered = [
      ...pr.comments.nodes.filter((c) => c.author?.login === ME).map((c) => c.createdAt),
      ...pr.reviews.nodes.filter((r) => r.author?.login === ME).map((r) => r.submittedAt),
    ].sort().pop() ?? "";
    const unanswered = pr.reviews.nodes.filter((r) => r.author && r.author.__typename !== "Bot" && r.author.login !== ME && /\S/.test(r.body) && r.submittedAt > answered).length;
    const open = pr.reviewThreads.nodes.filter((t) => !t.isResolved).length + unanswered;
    const changes = pr.reviewDecision === "CHANGES_REQUESTED" || human.some((r) => r.state === "CHANGES_REQUESTED");
    const state = changes ? "changes requested" : pr.reviewDecision === "APPROVED" ? "approved" : human.length ? "reviewed" : "awaiting review";
    return {
      number: pr.number, title: pr.title, url: pr.url, branch: pr.headRefName,
      ci: STATE_CI[pr.commits.nodes[0]?.commit.statusCheckRollup?.state] ?? "none",
      priority: changes ? 0 : open ? 1 : pr.reviewDecision === "APPROVED" ? 3 : 2,
      state, open,
      detail: [
        state,
        open ? `${open} open thread${open === 1 ? "" : "s"}` : null,
        pr.isDraft ? "draft" : null,
        pr.baseRefName !== "main" ? `on ${pr.baseRefName}` : null,
      ].filter(Boolean).join(" · "),
    };
  }).sort((a, b) => a.priority - b.priority || a.number - b.number);
}

export default class PrReviews extends View {
  init(_props, cx) {
    this.groups = [];
    this.mine = [];
    this.refresh(cx);
    cx.timer.every(REFRESH_MS, (cx) => this.refresh(cx));
  }

  refresh(cx) {
    if (this.loading) return;
    this.loading = true;
    cx.notify();
    cx.spawn(async (cx) => {
      try {
        const [list, search] = await Promise.all([
          exec("gh", ["pr", "list", "--repo", REPO, "--state", "open", "--draft=false", "--limit", "200",
            "--json", "number,title,url,author,reviewDecision,createdAt,updatedAt,reviewRequests,additions,deletions,statusCheckRollup,baseRefName,headRefName"], { timeout: 60000 }),
          exec("gh", ["api", "graphql", "-f", `query=${MINE_QUERY}`,
            "-f", `q=repo:${REPO} is:pr is:open author:${ME} -label:"${RESPONDED_LABEL}"`], { timeout: 60000 }),
        ]);
        if (list.code !== 0) throw new Error(list.stderr.trim());
        if (search.code !== 0) throw new Error(search.stderr.trim());
        this.groups = incoming(JSON.parse(list.stdout));
        this.mine = mine(JSON.parse(search.stdout).data.search.nodes);
        this.loaded = true;
        this.error = null;
        this.fetchedAt = new Date();
      } catch (e) {
        this.error = String(e.message ?? e);
      } finally {
        this.loading = false;
        cx.notify();
      }
    });
  }

  row(pr, t, branch) {
    const ciColor = { green: t.ansi2, pending: t.blocked, failing: t.ansi1, none: t.dim }[pr.ci];
    const stateColor = pr.state === "changes requested" ? t.ansi1 : pr.state === "approved" ? t.ansi2 : t.dim;
    return h_flex().id(`pr-${pr.number}`).flex_none().px(8).py(5).gap(8).items_start().rounded(7).cursor_pointer()
      .when(Boolean(branch) && pr.branch === branch, (e) => e.bg(t.selected))
      .hover((s) => s.bg(t.hover))
      .on_click(() => exec("xdg-open", [pr.url]).catch(() => null))
      .child(div().mt(5).w(7).h(7).flex_none().rounded(4).bg(ciColor))
      .child(v_flex().flex_1().min_w(0).gap(1)
        .child(h_flex().gap(6).min_w(0)
          .child(div().flex_none().text_color(t.muted).child(`#${pr.number}`))
          .child(div().flex_1().min_w(0).truncate().child(pr.title)))
        .child(div().truncate().text_size(11).text_color(pr.state ? stateColor : t.dim).child(pr.detail)));
  }

  section(title, rows, t, branch, loaded) {
    const empty = loaded ? "None" : "Loading…";
    return v_flex().flex_none().gap(2)
      .child(h_flex().px(8).pt(8).pb(2).gap(6).text_size(11).text_color(t.muted)
        .child(div().font_semibold().child(title))
        .child(div().text_color(t.dim).child(loaded ? String(rows.length) : "")))
      .children(rows.length ? rows.map((pr) => this.row(pr, t, branch)) : [div().px(8).text_size(12).text_color(t.dim).child(empty)]);
  }

  render(_cx) {
    const t = theme(), branch = focusedBranch();
    const stamp = this.fetchedAt ? this.fetchedAt.toLocaleTimeString([], { hour: "numeric", minute: "2-digit" }) : "";
    return v_flex().id("pr-reviews").size_full().min_h(0).bg(t.background).text_color(t.foreground).text_size(13)
      .child(h_flex().h(36).flex_none().px(12).gap(8).items_center().border_b(1).border_color(t.border)
        .child(div().font_semibold().child("Reviews"))
        .child(div().flex_1())
        .child(div().text_size(11).text_color(t.dim).child(this.loading ? "Refreshing…" : stamp))
        .child(div().id("pr-reviews-refresh").px(6).py(2).rounded(5).text_size(11).text_color(t.muted).cursor_pointer()
          .hover((s) => s.bg(t.hover)).on_click((_e, cx) => this.refresh(cx)).child("↻")))
      .when(Boolean(this.error), (e) => e.child(div().px(12).py(6).text_size(11).text_color(t.ansi1).child(this.error)))
      .child(div().flex_1().min_h(0).relative()
        .child(v_flex().id("pr-reviews-list").absolute().inset_0().overflow_y_scroll().p(6).gap(4)
          .children(GROUPS.map((group) =>
            this.section(group, this.groups.find(([g]) => g === group)?.[1] ?? [], t, branch, this.loaded)))
          .child(this.section("Your PRs", this.mine, t, branch, this.loaded)))
        .child(Scrollbar.vertical("pr-reviews-list").absolute().inset_0()));
  }
}
