import matugen from "./matugen"
import hyprland from "./hyprland"
import tmux from "./tmux"
import gtk from "./gtk"
import lowBattery from "./battery"
import notifications from "./notifications"
import bluetooth from "./bluetooth"

export default function init() {
    try {
        gtk()
        tmux()
        matugen()
        lowBattery()
        notifications()
        hyprland()
        bluetooth()
    } catch (error) {
        logError(error)
    }
}
