{ pkgs, vars, ...}:

with vars;
let
  output =
    [
      mainMonitor
      secondMonitor
      thirdMonitor
    ];
in
{
  home.packages = [ pkgs.playerctl ];
  programs.waybar = {
    enable = true;
    package = pkgs.waybar;
    systemd ={
      enable = true;
      target = "sway-session.target";
    };

    style = ''
      @define-color base03    #002b36;
      @define-color base02    #073642;
      @define-color base01    #586e75;
      @define-color base00    #657b83;
      @define-color base0     #839496;
      @define-color base1     #93a1a1;
      @define-color base2     #eee8d5;
      @define-color base3     #fdf6e3;
      @define-color yellow    #b58900;
      @define-color orange    #cb4b16;
      @define-color red       #dc322f;
      @define-color magenta   #d33682;
      @define-color violet    #6c71c4;
      @define-color blue      #268bd2;
      @define-color cyan      #2aa198;
      @define-color green     #859900;

      * {
        font-family: "JetBrainsMono Nerd Font";
        font-size: 13px;
        font-weight: normal;
      }

      window#waybar {
        background-color: @base03;
        color: @base3;
        transition-property: background-color;
        transition-duration: 0.5s;
        border-radius: 0px;
        transition-duration: .5s;
        margin: 0px;
      }

      window#waybar.hidden {
        opacity: 0.2;
      }

      tooltip {
        background: @base02;
      }

      tooltip label {
        color: @base3;
      }

      #workspaces {
        border-radius: 5px;
        transition: none;
        background: @base02;
        margin: 5px 0px 5px 5px;
      }

      #workspaces button{
        color: @base3;
        background: @base02;
        border-radius: 5px;
        padding: 0px 8px 0px 8px;
        margin: 0;
      }

      #workspaces button:hover {
        background: @cyan;
        color: @base3;
      }

      #workspaces button.active {
        color: @base03;
        background: @violet;
      }

      #custom-menu,
      #clock,
      #battery,
      #cpu,
      #temperature,
      #backlight,
      #network,
      #pulseaudio,
      #memory,
      #mpris {
        padding: 0px 20px 0px 20px;
        margin:5px 0px 5px 0px;
        border-radius: 5px;
        color: @violet;
        background-color: @base02;
      }

      /* ========= APP LAUNCHER ========= */

      #custom-menu {
        font-size: 14px;
        color: @base02;
        background-color: @violet;
        border-radius: 5px;
        padding: 0px 15px 0px 5px;
        margin: 5px 5px 5px 5px;
      }

      /* ========= CLOCK ========= */

      #clock.icon {
        font-size: 14px;
        background-color: @base02;
        border-radius: 5px 0px 0px 5px;
        margin: 5px 0px 5px 5px;
        padding: 0px 10px 0px 10px;
      }

      #clock.time {
        color: @base3;
        background-color: @base02;
        border-radius: 0px 5px 5px 0px;
        margin: 5px 5px 5px 0px;
        padding: 0px 11px 0px 5px;
      }

      /* ========= DATE ========= */

      #clock.dateicon {
        font-size: 14px;
        background-color: @base02;
        border-radius: 5px 0px 0px 5px;
        margin: 5px 0px 5px 5px;
        padding: 0px 10px 0px 10px;
      }

      #clock.date {
        color: @base3;
        background-color: @base02;
        border-radius: 0px 5px 5px 0px;
        margin: 5px 5px 5px 0px;
        padding: 0px 11px 0px 5px;
      }

      /* ========= VOLUME ========= */

      #pulseaudio.icon {
        font-size: 14px;
        background-color: @base02;
        border-radius: 5px 0px 0px 5px;
        margin: 5px 0px 5px 5px;
        padding: 0px 5px 0px 10px;
      }

      #pulseaudio.sound {
        color: @base3;
        background-color: @base02;
        border-radius: 0px 5px 5px 0px;
        margin: 5px 5px 5px 0px;
        padding: 0px 10px 0px 5px;
      }

      /* ========= NETWORK ========= */

      #network.icon {
        font-size: 14px;
        background-color: @base02;
        border-radius: 5px 0px 0px 5px;
        margin: 5px 0px 5px 5px;
        padding: 0px 5px 0px 10px;
      }

      #network.strength {
        color: @base3;
        background-color: @base02;
        border-radius: 0px 5px 5px 0px;
        margin: 5px 5px 5px 0px;
        padding: 0px 10px 0px 5px;
      }

      #tray {
        margin: 5px 5px 5px 0px;
        padding: 0px 10px 0px 5px;
      }

      /* ========= BATTERY ========= */

      #battery.icon {
        background-color: @base02;
        border-radius: 5px 0px 0px 5px;
        margin: 5px 0px 5px 5px;
        padding: 0px 5px 0px 10px;
      }

      #battery.value {
        color: @base3;
        background-color: @base02;
        border-radius: 0px 5px 5px 0px;
        margin: 5px 5px 5px 0px;
        padding: 0px 10px 0px 5px;
      }

      /* ========= WINDOW ========= */

      #window.icon {
        color: @violet;
        background-color: @base02;
        border-radius: 5px 0px 0px 5px;
        margin: 5px 0px 5px 10px;
        padding: 0px 10px 0px 10px;
      }

      #window.title {
        color: @base3;
        background-color: @base02;
        border-radius: 0px 5px 5px 0px;
        margin: 5px 5px 5px 0px;
        padding: 0px 11px 0px 10px;
      }

      /* ========= CPU ========= */

      #cpu.icon {
        color: @violet;
        background-color: @base02;
        border-radius: 5px 0px 0px 5px;
        margin: 5px 0px 5px 5px;
        padding: 0px 5px 0px 10px;
      }

      #cpu.usage {
        color: @base3;
        background-color: @base02;
        border-radius: 0px 5px 5px 0px;
        margin: 5px 5px 5px 0px;
        padding: 0px 10px 0px 5px;
      }

      /* ========= TEMPERATURE ========= */

      #temperature.icon {
        font-size: 14px;
        color: @violet;
        background-color: @base02;
        border-radius: 5px 0px 0px 5px;
        margin: 5px 0px 5px 5px;
        padding: 0px 5px 0px 10px;
      }

      #temperature.value {
        color: @base3;
        background-color: @base02;
        border-radius: 0px 5px 5px 0px;
        margin: 5px 5px 5px 0px;
        padding: 0px 11px 0px 10px;
      }

      @keyframes blink {
        to {
          background-color: rgba(30, 34, 42, 0.5);
          color: #abb2bf;
        }
      }

      #battery.critical:not(.charging) {
        color: #f53c3c;
        animation-name: blink;
        animation-duration: 0.5s;
        animation-timing-function: linear;
        animation-iteration-count: infinite;
        animation-direction: alternate;
      }

      label:focus {
        background-color: #000000;
      }

      #mpris {
        font-size: 14px;
        background-color: @base02;
        border-radius: 5px;
        margin: 5px;
        padding: 0px 10px;
      }
    '';
    settings = {
      Main = {
        margin-top = 0;
        margin-left = 0;
        margin-bottom = 0;
        margin-right = 0;
        height = 0;
        layer = "top";
        position = "top";
        output = output;
        spacing = 0;
        modules-left = ["custom/menu" "hyprland/workspaces"];
        modules-center = ["clock#icon" "clock#time" "clock#dateicon" "clock#date"];
        modules-right = ["mpris" "pulseaudio#icon" "pulseaudio#sound" "battery#icon" "battery#value" "tray"];

        "hyprland/workspaces" = {
          disable-scroll = true;
          all-outputs = true;
          on-click = "activate";
          on-scroll-up = "hyprctl dispatch workspace e+1";
          on-scroll-down = "hyprctl dispatch workspace e-1";
          persistent_workspaces = {
            "1" = [];
            "2" = [];
            "3" = [];
            "4" = [];
            "5" = [];
            "6" = [];
            "7" = [];
            "8" = [];
            "9" = [];
            "10" = [];
          };
        };

        "hyprland/window#icon" = {
          format = "";
          separate-outputs = false;
        };

        "hyprland/window#title" = {
          max-length = 30;
          format = "{}";
          separate-outputs = false;
        };

        backlight = {
          device = "eDP-1";
          max-length = "4";
          format = "{icon}";
          tooltip-format = "{percent}%";
          format-icons = ["" "" "" "" "" "" ""];
          on-click = "";
          on-scroll-up = "brightnessctl set 10%-";
          on-scroll-down = "brightnessctl set +10%";
        };

        "cpu#icon" = {
          interval = 10;
          format = "";
          max-length = 10;
        };

        "cpu#usage" = {
          interval = 10;
          format = "{usage}%";
          max-length = 10;
        };

        "temperature#icon" = {
          format = "";
          on-click = "psensor";
        };

        "temperature#value" = {
          hwmon-path = "/sys/class/hwmon/hwmon4/temp1_input";
          format = "{temperatureC}°C";
          on-click = "psensor";
        };

        "battery#icon" = {
          interval = 60;
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{icon}";
          format-charging = "󰂄";
          format-plugged = "";
          format-full = "";
          format-icons = ["󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹"];
          max-length = 25;
        };

        "battery#value" = {
          interval = 60;
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{capacity}%";
          format-alt = "{time}";
          max-length = 25;
        };

        memory = {
          interval = 30;
          format = "  {}%";
          format-alt = " {used:0.1f}G";
          max-length = 10;
        };

        "pulseaudio#icon" = {
          format = "{icon}";
          format-bluetooth = "{icon} ";
          format-bluetooth-muted = "󰝟 ";
          format-muted = "󰝟";
          format-icons = {
            headphone = "";
            hands-free = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = ["" "" ""];
          };
          on-click = "${pkgs.pamixer}/bin/pamixer -t";
          on-click-right = "${pkgs.pamixer}/bin/pamixer --default-source -t";
          on-click-middle = "${pkgs.pavucontrol}/bin/pavucontrol";
        };

        "pulseaudio#sound" = {
          format = "{volume}%";
          format-bluetooth = "{volume}%";
          format-bluetooth-muted = "{volume}%";
          format-muted = "muted";
          on-click = "${pkgs.pamixer}/bin/pamixer -t";
          on-click-right = "${pkgs.pamixer}/bin/pamixer --default-source -t";
          on-click-middle = "${pkgs.pavucontrol}/bin/pavucontrol";
        };

        "clock#icon" = {
          format = "";
        };

        "clock#time" = {
          format = "{:%I:%M %p}";
        };

        "clock#dateicon" = {
          format = "";
        };

        "clock#date" = {
          format = "{:%A, %B %d, %Y}";
          tooltip-format = "<tt><small>{calendar}</small></tt>";
          # on-click = "${pkgs.eww-wayland}/bin/eww open --toggle calendar --screen 0";
          calendar = {
            mode = "year";
            mode-mon-col = 3;
            weeks-pos = "right";
            on-scroll = 1;
          };
        };

        mpris = {
          format = "{status_icon}";
          status-icons = {
            stopped = "";
            playing = "󰏤";
            paused = "󰐎";
          };
        };

        "custom/menu" = {
          format = "<span font='16'></span>";
          on-click = ''${pkgs.eww-wayland}/bin/eww open --toggle menu --screen 0'';
          on-click-right = "${pkgs.wofi}/bin/wofi --show drun";
          tooltip = false;
        };
      };
    };
  };
}
