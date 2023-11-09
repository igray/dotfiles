#
#  Hyprland Configuration
#  Enable with "hyprland.enable = true;"
#

{ config, lib, system, pkgs, unstable, vars, host, ... }:

with lib;
with host;
{
  options = {
    hyprland = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };

  config = mkIf (config.hyprland.enable) {
    wlwm.enable = true;                       # Wayland Window Manager

    environment =
    let
      exec = "exec dbus-launch Hyprland";
    in
    {
      loginShellInit = ''
        if [ -z $DISPLAY ] && [ "$(tty)" = "/dev/tty1" ]; then
          ${exec}
        fi
      '';                                     # Start from TTY1

      variables = {
        XDG_CURRENT_DESKTOP="Hyprland";
        XDG_SESSION_TYPE="wayland";
        XDG_SESSION_DESKTOP="Hyprland";
      };
      sessionVariables = {
        QT_QPA_PLATFORM = "wayland";
        QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";

        GDK_BACKEND = "wayland";
        WLR_NO_HARDWARE_CURSORS = "1";
        MOZ_ENABLE_WAYLAND = "1";
      };
      systemPackages = with pkgs; [
        gammastep       # Nightlight
        grim            # Grab Images
        hyprpaper       # Background manager
        slurp           # Region Selector
        swappy          # Snapshot Editor
        swayidle        # Idle Daemon
        swaylock        # Lock Screen
        wl-clipboard    # Clipboard
        wlr-randr       # Monitor Settings
        udiskie         # Removable drive automount
      ];
    };

    security.pam.services.swaylock = {
      text = ''
       auth include login
      '';
    };

    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --time-format '%I:%M %p | %a • %h | %F' --cmd Hyprland";
        };
      };
      vt = 7;
    };

    programs = {
      hyprland = {                            # Window Manager
        enable = true;
        package = unstable.hyprland;
      };
    };

    systemd.sleep.extraConfig = ''
      AllowSuspend=yes
      AllowHibernation=no
      AllowSuspendThenHibernate=no
      AllowHybridSleep=yes
    '';                                       # Clamshell Mode

    nix.settings = {
      substituters = ["https://hyprland.cachix.org"];
      trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
    };                                        # Cache

    home-manager.users.${vars.user} =
    let
      hyprlandConf = ''
        monitor=${toString mainMonitor},2256x1504@60,0x0,1.25
        monitor=${toString secondMonitor},3840x2160@60,2256x0,1.75
        monitor=${toString thirdMonitor},3840x2160@60,2256x0,1.75
        monitor=,highres,auto,auto

        general {
          border_size=1
          gaps_in=5
          gaps_out=10
          col.active_border = rgba(6c71c4ff)
          col.inactive_border = rgba(073642ff)
          layout=master
        }

        decoration {
          rounding=3
          col.shadow = rgba(1a1a1aee)
        }

        animations {
          enabled = true
          bezier = myBezier, 0.05, 0.9, 0.1, 1.05

          animation = windows, 1, 7, myBezier
          animation = windowsOut, 1, 7, default, popin 80%
          animation = border, 1, 10, default
          animation = borderangle, 1, 8, default
          animation = fade, 1, 7, default
          animation = workspaces, 1, 6, default
        }

        input {
          kb_layout=us
          kb_options=caps:swapescape
          follow_mouse=1
          repeat_delay=250
          numlock_by_default=1
          accel_profile=flat
          sensitivity=0
          touchpad {
            natural_scroll=true
            clickfinger_behavior=true
            tap-to-click=false
          }
        }

        gestures {
          workspace_swipe=true
          workspace_swipe_numbered = true
        }

        master {
          new_is_master=false
        }

        dwindle {
          pseudotile=true
          preserve_split=true
        }

        misc {
          disable_hyprland_logo=true
          disable_splash_rendering=true
          mouse_move_enables_dpms=true
          key_press_enables_dpms=true
        }

        debug {
          damage_tracking=2
        }

        bindm=SUPER,mouse:272,movewindow
        bindm=SUPER,mouse:273,resizewindow

        bind=SUPER,Return,exec,${pkgs.${vars.terminal}}/bin/${vars.terminal}
        bind=SUPER,C,killactive,
        bind=SUPER,Escape,exit,
        bind=SUPERSHIFT,S,exec,${pkgs.systemd}/bin/systemctl suspend
        bind=SUPERALT,L,exec,${pkgs.swaylock}/bin/swaylock
        bind=SUPER,F,exec,${pkgs.pcmanfm}/bin/pcmanfm
        bind=SUPERSHIFT,F,togglefloating,
        bind=SUPER,Space,exec, pkill wofi || ${pkgs.wofi}/bin/wofi --show drun
        bind=SUPER,P,pseudo,
        bind=SUPER,M,layoutmsg,swapwithmaster auto
        bind=SUPER,Y,movetoworkspace,special:scratch
        bind=SUPER,S,togglespecialworkspace,scratch
        bind=SUPER,Z,fullscreen,
        bind=SUPER,R,forcerendererreload
        bind=SUPERSHIFT,R,exec,${pkgs.hyprland}/bin/hyprctl reload
        bind=ALT,tab,focuscurrentorlast
        bind=SUPERALT,J,togglespecialworkspace,journal

        bind=SUPER,left,movefocus,l
        bind=SUPER,right,movefocus,r
        bind=SUPER,up,movefocus,u
        bind=SUPER,down,movefocus,d

        bind=SUPER,H,movefocus,l
        bind=SUPER,L,movefocus,r
        bind=SUPER,K,movefocus,u
        bind=SUPER,J,movefocus,d
        bind=SUPERSHIFT,H,resizeactive,-10 0
        bind=SUPERSHIFT,L,resizeactive,10 0
        bind=SUPERSHIFT,K,resizeactive,0 -10
        bind=SUPERSHIFT,J,resizeactive,0 10

        bind=SUPERSHIFT,left,movewindow,l
        bind=SUPERSHIFT,right,movewindow,r
        bind=SUPERSHIFT,up,movewindow,u
        bind=SUPERSHIFT,down,movewindow,d

        bind=SUPER,1,workspace,1
        bind=SUPER,2,workspace,2
        bind=SUPER,3,workspace,3
        bind=SUPER,4,workspace,4
        bind=SUPER,5,workspace,5
        bind=SUPER,6,workspace,6
        bind=SUPER,7,workspace,7
        bind=SUPER,8,workspace,8
        bind=SUPER,9,workspace,9
        bind=SUPER,0,workspace,10
        bind=SUPERALT,right,workspace,+1
        bind=SUPERALT,left,workspace,-1

        bind=SUPERSHIFT,1,movetoworkspace,1
        bind=SUPERSHIFT,2,movetoworkspace,2
        bind=SUPERSHIFT,3,movetoworkspace,3
        bind=SUPERSHIFT,4,movetoworkspace,4
        bind=SUPERSHIFT,5,movetoworkspace,5
        bind=SUPERSHIFT,6,movetoworkspace,6
        bind=SUPERSHIFT,7,movetoworkspace,7
        bind=SUPERSHIFT,8,movetoworkspace,8
        bind=SUPERSHIFT,9,movetoworkspace,9
        bind=SUPERSHIFT,0,movetoworkspace,10
        bind=SUPERSHIFT,right,movetoworkspace,+1
        bind=SUPERSHIFT,left,movetoworkspace,-1

        bind=,print,exec,${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" - | ${pkgs.swappy}/bin/swappy -f - -o ~/Pictures/$(date +%Hh_%Mm_%Ss_%d_%B_%Y).png && notify-send "Saved to ~/Pictures/$(date +%Hh_%Mm_%Ss_%d_%B_%Y).png"

        bind=,XF86AudioLowerVolume,exec,${pkgs.pamixer}/bin/pamixer -d 10
        bind=,XF86AudioRaiseVolume,exec,${pkgs.pamixer}/bin/pamixer -i 10
        bind=,XF86AudioMute,exec,${pkgs.pamixer}/bin/pamixer -t
        bind=SUPER_L,c,exec,${pkgs.pamixer}/bin/pamixer --default-source -t
        bind=,XF86AudioMicMute,exec,${pkgs.pamixer}/bin/pamixer --default-source -t
        bind=,XF86MonBrightnessDown,exec,${pkgs.light}/bin/light -U 10
        bind=,XF86MonBrightnessUP,exec,${pkgs.light}/bin/light -A 10
        bindl=,switch:Lid Switch,exec,$HOME/.config/hypr/script/clamshell.sh

        windowrule = workspace special:scratch, title:^(Authenticator)$
        windowrule = workspace special:journal, ^(Logseq)$
        windowrule = float, ^(org\.gnome\.Settings)$
        windowrule = maxsize 600 800, ^(pavucontrol)$
        windowrule = center, ^(pavucontrol)$
        windowrule = float, ^(pavucontrol)$
        windowrule = tile, ^(libreoffice)$
        windowrule = nofullscreenrequest, ^(.*libreoffice.*)$
        windowrule = float, ^(blueman-manager)$
        windowrule = size 490 600, ^(org.gnome.Calculator)$
        windowrule = float, ^(org.gnome.Calculator)$
        windowrule = idleinhibit focus, title:^(Google Meet.*)$
        windowrule = idleinhibit focus, title:^(Zoom Meeting.*)$

        exec-once=dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
        exec-once=${pkgs.hyprpaper}/bin/hyprpaper
        exec-once=${unstable.waybar}/bin/waybar
        exec-once=${unstable.eww-wayland}/bin/eww daemon
        exec-once=${pkgs.blueman}/bin/blueman-applet
        exec-once=${pkgs.networkmanagerapplet}/bin/nm-applet --indicator
        exec-once=${pkgs.udiskie}/bin/udiskie
        exec-once=${pkgs.gammastep}/bin/gammastep -m wayland -l 30.318276:-97.742119
        exec-once=${pkgs.swayidle}/bin/swayidle -w timeout 600 '${pkgs.swaylock}/bin/swaylock -f' timeout 1200 '${pkgs.systemd}/bin/systemctl suspend' after-resume '${config.programs.hyprland.package}/bin/hyprctl dispatch dpms on' before-sleep '${pkgs.swaylock}/bin/swaylock -f && ${config.programs.hyprland.package}/bin/hyprctl dispatch dpms off'
      '';
    in
    {
      xdg.configFile."hypr/hyprland.conf".text = hyprlandConf;

      programs.swaylock.settings = {
        color = "000000f0";
        font-size = "24";
        indicator-idle-visible = false;
        indicator-radius = 100;
        indicator-thickness = 20;
        inside-color = "00000000";
        inside-clear-color = "00000000";
        inside-ver-color = "00000000";
        inside-wrong-color = "00000000";
        key-hl-color = "79b360";
        line-color = "000000f0";
        line-clear-color = "000000f0";
        line-ver-color = "000000f0";
        line-wrong-color = "000000f0";
        ring-color = "ffffff50";
        ring-clear-color = "bbbbbb50";
        ring-ver-color = "bbbbbb50";
        ring-wrong-color = "b3606050";
        text-color = "ffffff";
        text-ver-color = "ffffff";
        text-wrong-color = "ffffff";
        show-failed-attempts = true;
      };

      home.file = {
        ".config/hypr/script/clamshell.sh" = {
          text = ''
            #!/bin/sh

            if grep open /proc/acpi/button/lid/LID/state; then
              ${config.programs.hyprland.package}/bin/hyprctl keyword monitor "eDP-1, 2256x1504, 0x0, 1"
            else
              if [[ `hyprctl monitors | grep "Monitor" | wc -l` != 1 ]]; then
                ${config.programs.hyprland.package}/bin/hyprctl keyword monitor "eDP-1, disable"
              else
                ${pkgs.swaylock}/bin/swaylock -f
                ${pkgs.systemd}/bin/systemctl sleep
              fi
            fi
          '';
          executable = true;
        };
      };
    };
  };
}
