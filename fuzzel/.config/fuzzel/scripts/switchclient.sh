#!/usr/bin/env bash

WINDOWS=$(hyprctl clients -j | jq -r '.[] | .title + " | " + .class + " | " + (.pid | tostring)')

CHENTRY=$(echo "$WINDOWS" | fuzzel -d --prompt "Window: ")

if [ -n "$CHENTRY" ] ; then
  PID=$(echo "$CHENTRY" | awk '{print $NF}')
  hyprctl dispatch focuswindow "pid:$PID"
fi
