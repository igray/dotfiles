{ pkgs, vars, ... }:

let
  colors = import ./colors.nix;
in
{
  home.packages = [ pkgs.fuzzel ];
  home.file = {
    ".config/fuzzel/fuzzel.ini" = with colors.scheme.solarized; {
      text = ''
        font=Cantrell:size=12
        terminal=${pkgs.${vars.terminal}}/bin/${vars.terminal}
        inner-pad=8

        [colors]
        background = ${bg}ff
        text = ${text}ff
        match = ${green}ff
        selection = ${bg}ff
        selection-text = ${orange}ff
        border = ${bg}ff

        [border]
        radius=5
      '';
    };
    ".config/fuzzel/switchclient.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash

        WINDOWS=$(hyprctl clients -j | jq -r '.[] | .title + " | " + .class + " | " + (.pid | tostring)')

        CHENTRY=$(echo "$WINDOWS" | fuzzel -d --prompt "Window: ")

        if [ -n "$CHENTRY" ] ; then
          PID=$(echo "$CHENTRY" | awk '{print $NF}')
          hyprctl dispatch focuswindow "pid:$PID"
        fi
      '';
    };
  };
}
