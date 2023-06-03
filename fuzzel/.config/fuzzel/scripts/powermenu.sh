#!/bin/bash

entries="Reboot\0icon\x1fsystem-reboot-symbolic\nShutdown\0icon\x1fsystem-shutdown-symbolic\nLogout\0icon\x1fsystem-log-out-symbolic\nSuspend\0icon\x1fmedia-playback-pause-symbolic"

selected=$(echo -e $entries|fuzzel -d -w 10 -l 5| awk '{print tolower($2)}')

case $selected in
  logout)
    exec hyprctl dispatch exit NOW;;
  suspend)
    exec systemctl suspend;;
  reboot)
    exec systemctl reboot;;
  shutdown)
    exec systemctl poweroff -i;;
esac
