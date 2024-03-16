import matugen from "./matugen"
import hyprland from "./hyprland"
import tmux from "./tmux"
import gtk from "./gtk"
import lowBattery from "./battery"
import swww from "./swww"
import notifications from "./notifications"
import bluetooth from "./bluetooth"

try {
    gtk()
    tmux()
    matugen()
    lowBattery()
    notifications()
    hyprland()
    swww()
    bluetooth()
} catch (error) {
    logError(error)
}
