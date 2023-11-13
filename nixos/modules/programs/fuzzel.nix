#
#  System Menu
#

{ config, lib, pkgs, vars, ... }:

let
  colors = import ../theming/colors.nix;
in
{
  config = lib.mkIf (config.wlwm.enable) {
    home-manager.users.${vars.user} = {
      home = {
        packages = with pkgs; [
          fuzzel
        ];
      };

      home.file = {
        ".config/fuzzel/fuzzel.ini" = with colors.scheme.solarized; {
          text = ''
            font=Cantrell:size=12
            terminal=${pkgs.wezterm}/bin/wezterm start
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
    };
  };
}
