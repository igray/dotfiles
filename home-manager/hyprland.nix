{ pkgs, vars, ... }:
let
  mainMonitor = "BOE 0x0BCA";
  secondMonitor = "Dell Inc. DELL UP2720Q BJMDMX2";

  playerctl = "${pkgs.playerctl}/bin/playerctl";
  brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";
  pactl = "${pkgs.pulseaudio}/bin/pactl";
in
{
  xdg.desktopEntries."org.gnome.Settings" = {
    name = "Settings";
    comment = "Gnome Control Center";
    icon = "org.gnome.Settings";
    exec = "env XDG_CURRENT_DESKTOP=gnome ${pkgs.gnome.gnome-control-center}/bin/gnome-control-center";
    categories = [ "X-Preferences" ];
    terminal = false;
  };

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    xwayland.enable = true;

    settings = {
      monitor = [
        "desc:${toString secondMonitor},3840x2160@60.0,0x0,1.666667"
        "desc:${toString mainMonitor},2256x1504@60.0,194x1296,1.175"
        ",preferred,auto,auto"
      ];

      workspace = [
        "1,monitor:desc:${toString secondMonitor},default:true"
        "2,monitor:desc:${toString secondMonitor}"
        "3,monitor:desc:${toString secondMonitor}"
        "4,monitor:desc:${toString secondMonitor}"
        "5,monitor:desc:${toString secondMonitor}"
        "6,monitor:desc:${toString mainMonitor},default:true"
        "7,monitor:desc:${toString mainMonitor}"
        "8,monitor:desc:${toString mainMonitor}"
        "9,monitor:desc:${toString mainMonitor}"
        "10,monitor:desc:${toString mainMonitor}"
      ];

      general = {
        layout = "master";
        resize_on_border = true;
      };

      decoration = {
        drop_shadow = "yes";
        shadow_range = 8;
        shadow_render_power = 2;
        "col.shadow" = "rgba(00000044)";

        dim_inactive = false;

        blur = {
          enabled = true;
          size = 8;
          passes = 3;
          new_optimizations = "on";
          noise = 0.01;
          contrast = 0.9;
          brightness = 0.8;
        };
      };

      animations = {
        enabled = "yes";
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        animation = [
          "windows, 1, 5, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };

      input = {
        kb_layout = "us";
        kb_options = "caps:swapescape";
        follow_mouse = 1;
        repeat_delay = 250;
        numlock_by_default = 1;
        sensitivity = 0.5;
        float_switch_override_focus = 2;
        touchpad = {
          natural_scroll = true;
          clickfinger_behavior = true;
          tap-to-click = false;
          disable_while_typing = true;
        };
      };

      gestures = {
        workspace_swipe = true;
      };

      master = {
        new_is_master = false;
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        mouse_move_enables_dpms = true;
        key_press_enables_dpms = true;
      };

      debug = {
        damage_tracking = 2;
      };

      bindm = [
        "SUPER,mouse:272,movewindow"
        "SUPER,mouse:273,resizewindow"
      ];

      bind = let
        e = "exec, ags -b hypr";
      in [
        "CTRL SHIFT, R,  ${e} quit; ags -b hypr"
        "SUPER, Space,   ${e} -t launcher"
        ", XF86PowerOff, ${e} -t 'powermenu.shutdown()'"
        "SUPER, Tab,     ${e} -t overview"
        ", XF86Launch4,  ${e} -r 'recorder.start()'"
        ",Print,         ${e} -r 'recorder.screenshot()'"
        "SHIFT,Print,    ${e} -r 'recorder.screenshot(true)'"
        "SUPERALT,L,     ${e} -r 'swaylock -f'"
        "SUPER,Return,exec,${pkgs.${vars.terminal}}/bin/${vars.terminal}"
        "SUPER,C,killactive,"
        "SUPER,Escape,exit,"
        "SUPERSHIFT,S,exec,${pkgs.systemd}/bin/systemctl suspend"
        "SUPER,F,exec,nautilus"
        "SUPERSHIFT,F,togglefloating,"
        "SUPER,P,pseudo,"
        "SUPER,M,layoutmsg,swapwithmaster auto"
        "SUPER,Y,movetoworkspace,special:scratch"
        "SUPER,S,togglespecialworkspace,scratch"
        "SUPER,Z,fullscreen,1"
        "SUPER,R,forcerendererreload"
        "SUPERSHIFT,R,exec,${pkgs.hyprland}/bin/hyprctl reload"
        "ALT,tab,focuscurrentorlast"
        "SUPERALT,J,togglespecialworkspace,journal"

        "SUPER,left,movefocus,l"
        "SUPER,right,movefocus,r"
        "SUPER,up,movefocus,u"
        "SUPER,down,movefocus,d"

        "SUPER,H,movefocus,l"
        "SUPER,L,movefocus,r"
        "SUPER,K,movefocus,u"
        "SUPER,J,movefocus,d"
        "SUPERSHIFT,H,resizeactive,-10 0"
        "SUPERSHIFT,L,resizeactive,10 0"
        "SUPERSHIFT,K,resizeactive,0 -10"
        "SUPERSHIFT,J,resizeactive,0 10"

        "SUPERSHIFT,left,movewindow,l"
        "SUPERSHIFT,right,movewindow,r"
        "SUPERSHIFT,up,movewindow,u"
        "SUPERSHIFT,down,movewindow,d"
        "SUPERCTRL,up,movewindow,mon:-1"
        "SUPERCTRL,down,movewindow,mon:+1"

        "SUPER,1,workspace,1"
        "SUPER,2,workspace,2"
        "SUPER,3,workspace,3"
        "SUPER,4,workspace,4"
        "SUPER,5,workspace,5"
        "SUPER,6,workspace,6"
        "SUPER,7,workspace,7"
        "SUPER,8,workspace,8"
        "SUPER,9,workspace,9"
        "SUPER,0,workspace,10"
        "SUPERALT,right,workspace,+1"
        "SUPERALT,left,workspace,-1"

        "SUPERSHIFT,1,movetoworkspace,1"
        "SUPERSHIFT,2,movetoworkspace,2"
        "SUPERSHIFT,3,movetoworkspace,3"
        "SUPERSHIFT,4,movetoworkspace,4"
        "SUPERSHIFT,5,movetoworkspace,5"
        "SUPERSHIFT,6,movetoworkspace,6"
        "SUPERSHIFT,7,movetoworkspace,7"
        "SUPERSHIFT,8,movetoworkspace,8"
        "SUPERSHIFT,9,movetoworkspace,9"
        "SUPERSHIFT,0,movetoworkspace,10"
        "SUPERSHIFT,right,movetoworkspace,+1"
        "SUPERSHIFT,left,movetoworkspace,-1"
      ];

      bindle = let e = "exec, ags -b hypr -r"; in [
        ",XF86MonBrightnessUp,   exec, ${brightnessctl} set +5%"
        ",XF86MonBrightnessDown, exec, ${brightnessctl} set  5%-"
        ",XF86AudioRaiseVolume,  exec, ${pactl} set-sink-volume @DEFAULT_SINK@ +5%"
        ",XF86AudioLowerVolume,  exec, ${pactl} set-sink-volume @DEFAULT_SINK@ -5%"
      ];

      bindl =  [
        ",XF86AudioPlay,    exec, ${playerctl} play-pause"
        ",XF86AudioStop,    exec, ${playerctl} pause"
        ",XF86AudioPause,   exec, ${playerctl} pause"
        ",XF86AudioPrev,    exec, ${playerctl} previous"
        ",XF86AudioNext,    exec, ${playerctl} next"
        ",XF86AudioMicMute, exec, ${pactl} set-source-mute @DEFAULT_SOURCE@ toggle"
        ",switch:Lid Switch,exec,$HOME/.config/hypr/script/clamshell.sh"
      ];

      windowrule = let
        f = regex: "float, ^(${regex})$";
      in [
		(f "org.gnome.Calculator")
		(f "org.gnome.Nautilus")
		(f "pavucontrol")
		(f "nm-connection-editor")
		(f "blueberry.py")
		(f "org.gnome.Settings")
		(f "org.gnome.design.Palette")
		(f "Color Picker")
		(f "xdg-desktop-portal")
		(f "xdg-desktop-portal-gnome")
		(f "transmission-gtk")
		(f "com.github.Aylur.ags")
        "workspace special:scratch, title:^(Authenticator)$"
        "workspace special:journal, ^(Logseq)$"
        "maxsize 600 800, ^(pavucontrol)$"
        "center, ^(pavucontrol)$"
        "tile, ^(libreoffice)$"
        "float, ^(blueman-manager)$"
        "size 490 600, ^(org.gnome.Calculator)$"
        "idleinhibit focus, title:^(Google Meet.*)$"
        "idleinhibit focus, title:^(Zoom Meeting.*)$"
      ];

      env = [
        "WLR_NO_HARDWARE_CURSORS,1"
        "QT_QPA_PLATFORM,wayland"
        "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
        "GDK_BACKEND,wayland"
        "WLR_NO_HARDWARE_CURSORS,1"
        "MOZ_ENABLE_WAYLAND,1"
        "NIXOS_OZONE_WL,1"
        "_JAVA_AWT_WM_NONREPARENTING,1"
        "AWT_TOOLKIT,MToolkit"
        "SSH_AUTH_SOCK,$XDG_RUNTIME_DIR/keyring/ssh"
      ];

      exec-once = [
        "ags -b hypr"
        "hyprctl setcursor Qogir 24"
        "${pkgs.systemd}/bin/systemctl start --user gnome-keyring.service"
        "${pkgs.gammastep}/bin/gammastep -m wayland -l 30.318276:-97.742119"
        "${pkgs.swayidle}/bin/swayidle -w timeout 600 '${pkgs.swaylock}/bin/swaylock -f' timeout 3600 '${pkgs.systemd}/bin/systemctl suspend' after-resume 'hyprctl dispatch dpms on' before-sleep '${pkgs.swaylock}/bin/swaylock -f && hyprctl dispatch dpms off'"
        "${pkgs.hyprpaper}/bin/hyprpaper"
        "rfkill unblock bluetooth"
      ];
    };
  };

  programs.swaylock = {
    enable = true;
    settings = {
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
  };

  services.gnome-keyring = {
    enable = true;
    components = [ "secrets" "ssh" ];
  };

  home.file = {
    ".config/hypr/script/clamshell.sh" = {
      text = ''
        #!/bin/sh

        if grep open /proc/acpi/button/lid/LID/state; then
          hyprctl keyword monitor "eDP-1, 2256x1504, 0x0, 1"
        else
          if [[ `hyprctl monitors | grep "Monitor" | wc -l` != 1 ]]; then
            hyprctl keyword monitor "eDP-1, disable"
          else
            ~/.config/hypr/script/lock.sh
            systemctl sleep
          fi
        fi
      '';
      executable = true;
    };
    ".config/hypr/hyprpaper.conf" = {
      text = ''
        preload = ~/.local/wallchange/mywallpaper.jpg
        wallpaper = desc:${toString mainMonitor},~/.local/wallchange/mywallpaper.jpg
        wallpaper = desc:${toString secondMonitor},~/.local/wallchange/mywallpaper.jpg
      '';
    };
  };
}
