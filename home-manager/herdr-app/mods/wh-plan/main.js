/**
 * Shows the workforce-health plan that the `wh-next` skill keeps in
 * `~/Work/cp/ats/workforce_health_plan.md`: by default its Next up, In flight
 * and Waiting on decisions sections, or the whole file. Read-only; run
 * `/wh-next` to refresh the file. Re-reads it every 30 seconds.
 */

import { View, div } from "gpui-kit";
import { v_flex, h_flex, TextView } from "gpui-base";
import { exec, home, readTextFile, theme } from "herdr";

const PLAN = `${home()}/Work/cp/ats/workforce_health_plan.md`;
const SUMMARY = ["Next up", "In flight", "Waiting on decisions"];
const REFRESH_MS = 30000;

function summary(text) {
  const sections = text.split(/^(?=## )/m);
  const asOf = /As of [^\n]+/.exec(text)?.[0] ?? "";
  const kept = sections.filter((s) => SUMMARY.some((name) => s.startsWith(`## ${name}`)));
  return { asOf, body: kept.join("\n") };
}

const stripMarkers = (text) => text.replace(/^<!-- wh:(gen|end) [^>]*-->\n?/gm, "");

const cells = (line) => line.trim().replace(/^\||\|$/g, "").split(/(?<!\\)\|/).map((c) => c.trim());

// A narrow panel wraps table cells into unreadable columns, so each row becomes
// a list item: its first two cells as the line, the rest as "Header: value".
function tablesToLists(text) {
  return text.replace(/(?:^\|.*\|[ \t]*(?:\n|$))+/gm, (table) => {
    const [head, , ...rows] = table.trim().split("\n").map(cells);
    return rows.map((row) => {
      const [first, second, ...rest] = row;
      const details = rest.map((value, i) => (value ? `${head[i + 2]}: ${value}` : null)).filter(Boolean).join(" · ");
      return `- ${first}${second ? ` ${second}` : ""}${details ? `  \n  ${details}` : ""}`;
    }).join("\n") + "\n";
  });
}

export default class WhPlan extends View {
  init(_props, cx) {
    this.full = false;
    this.text = null;
    this.load(cx);
    cx.timer.every(REFRESH_MS, (cx) => this.load(cx));
  }

  load(cx) {
    cx.spawn(async (cx) => {
      const text = await readTextFile(PLAN).catch(() => null);
      if (text !== this.text) { this.text = text; cx.notify(); }
    });
  }

  toggle(label, active, onClick, t) {
    return div().id(`wh-${label}`).px(8).py(2).rounded(5).text_size(11).cursor_pointer()
      .text_color(active ? t.foreground : t.muted).when(active, (e) => e.bg(t.selected))
      .hover((s) => s.bg(t.hover)).on_click(onClick).child(label);
  }

  render(_cx) {
    const t = theme();
    const plan = this.text === null ? null : tablesToLists(stripMarkers(this.text));
    const { asOf, body } = plan ? summary(plan) : { asOf: "", body: "" };
    return v_flex().id("wh-plan").size_full().min_h(0).bg(t.background).text_color(t.foreground).text_size(13)
      .child(h_flex().h(36).flex_none().px(12).gap(6).items_center().border_b(1).border_color(t.border)
        .child(div().font_semibold().child("WH Plan"))
        .child(div().text_size(11).text_color(t.dim).child(asOf))
        .child(div().flex_1())
        .child(this.toggle("Summary", !this.full, (_e, cx) => { this.full = false; cx.notify(); }, t))
        .child(this.toggle("Full", this.full, (_e, cx) => { this.full = true; cx.notify(); }, t))
        .child(div().id("wh-open").px(6).py(2).rounded(5).text_size(11).text_color(t.muted).cursor_pointer()
          .hover((s) => s.bg(t.hover)).on_click(() => exec("xdg-open", [PLAN]).catch(() => null)).child("↗")))
      .child(plan === null
        ? div().p(12).text_size(12).text_color(t.dim).child(`No plan at ${PLAN}. Run /wh-next to write it.`)
        : div().flex_1().min_h(0).px(12).py(8).text_size(12)
          .child(TextView.markdown("wh-plan-text", this.full ? plan : body).selectable(true).scrollable(true).size_full()));
  }
}
