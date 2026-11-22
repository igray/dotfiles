/**
 * Hands Herdr notifications to the desktop notification daemon.
 *
 * A layout opts in with `"toast": "system-toast"` on its root node. Herdr then
 * opens this mod as an overlay for every notification, with props
 * `{title, body, level, icon, action, timeout, overlay}`. The mod forwards the
 * title and body to `notify-send` and closes its overlay at once, so nothing
 * is drawn in the window. The notification's click `action` is not forwarded.
 */

import { View, div } from "gpui-kit";
import { props, closeOverlay, exec } from "herdr";

export default class SystemToast extends View {
  init(_props, cx) {
    const p = props() ?? {};
    if (!p.overlay) return;
    cx.spawn(async () => {
      try {
        await exec("notify-send", ["--app-name=Herdr", p.title ?? "Herdr", p.body ?? ""]);
      } finally {
        closeOverlay(p.overlay);
      }
    });
  }

  render() {
    return div();
  }
}
