import css from "style/style"
import matugen from "./matugen"
import hyprland from "./hyprland"
import tmux from "./tmux"
import gtk from "./gtk"
import lowBattery from "./battery"
import swww from "./swww"

export async function init() {
    const bluetooth = await Service.import("bluetooth")
    try {
        gtk()
        css()
        tmux()
        matugen()
        lowBattery()
        hyprland()
        css()
        swww()
        setTimeout(() => {
          bluetooth.enabled = true
        }, 2000)
    } catch (error) {
        logError(error)
    }
}
