{ inputs, pkgs, vars, ... }:
let
  hyprland = inputs.hyprland.packages.${pkgs.system}.hyprland;
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
    package = hyprland;
    systemd.enable = true;
    xwayland.enable = true;

    settings = {
      monitor = [
        "${toString vars.mainMonitor},2256x1504@60,0x0,1.25"
        "${toString vars.secondMonitor},3840x2160@60,2256x0,1.75"
        "${toString vars.thirdMonitor},3840x2160@60,2256x0,1.75"
        ",highres,auto,auto"
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
        workspace_swipe_numbered = true;
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
        "SUPER, Space,   ${e} -t applauncher"
        ", XF86PowerOff, ${e} -t powermenu"
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

#       ",print,exec,${pkgs.grim}/bin/grim -g \"$(${pkgs.slurp}/bin/slurp)\" - | ${pkgs.swappy}/bin/swappy -f - -o ~/Pictures/$(date +%Hh_%Mm_%Ss_%d_%B_%Y).png && notify-send \"Saved to ~/Pictures/$(date +%Hh_%Mm_%Ss_%d_%B_%Y).png\""

#       ",XF86AudioLowerVolume,exec,${pkgs.pamixer}/bin/pamixer -d 10"
#       ",XF86AudioRaiseVolume,exec,${pkgs.pamixer}/bin/pamixer -i 10"
#       ",XF86AudioMute,exec,${pkgs.pamixer}/bin/pamixer -t"
#       "SUPER_L,c,exec,${pkgs.pamixer}/bin/pamixer --default-source -t"
#       ",XF86AudioMicMute,exec,${pkgs.pamixer}/bin/pamixer --default-source -t"
#       ",XF86MonBrightnessDown,exec,${pkgs.light}/bin/light -U 10"
#       ",XF86MonBrightnessUP,exec,${pkgs.light}/bin/light -A 10"
      ];

      bindle = let e = "exec, ags -b hypr -r"; in [
        ",XF86MonBrightnessUp,   ${e} 'brightness.screen += 0.05; indicator.display()'"
        ",XF86MonBrightnessDown, ${e} 'brightness.screen -= 0.05; indicator.display()'"
        ",XF86KbdBrightnessUp,   ${e} 'brightness.kbd++; indicator.kbd()'"
        ",XF86KbdBrightnessDown, ${e} 'brightness.kbd--; indicator.kbd()'"
        ",XF86AudioRaiseVolume,  ${e} 'audio.speaker.volume += 0.05; indicator.speaker()'"
        ",XF86AudioLowerVolume,  ${e} 'audio.speaker.volume -= 0.05; indicator.speaker()'"
      ];

      bindl = let e = "exec, ags -b hypr -r"; in [
        ",XF86AudioPlay,    ${e} 'mpris?.playPause()'"
        ",XF86AudioStop,    ${e} 'mpris?.stop()'"
        ",XF86AudioPause,   ${e} 'mpris?.pause()'"
        ",XF86AudioPrev,    ${e} 'mpris?.previous()'"
        ",XF86AudioNext,    ${e} 'mpris?.next()'"
        ",XF86AudioMicMute, ${e} 'audio.microphone.isMuted = !audio.microphone.isMuted'"
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
        "nofullscreenrequest, ^(.*libreoffice.*)$"
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
        "${pkgs.swayidle}/bin/swayidle -w timeout 600 '${pkgs.swaylock}/bin/swaylock -f' after-resume 'hyprctl dispatch dpms on' before-sleep '${pkgs.swaylock}/bin/swaylock -f'"
        # "${pkgs.swayidle}/bin/swayidle -w timeout 600 '${pkgs.swaylock}/bin/swaylock -f' timeout 1200 '${pkgs.systemd}/bin/systemctl suspend' after-resume 'hyprctl dispatch dpms on' before-sleep '${pkgs.swaylock}/bin/swaylock -f && hyprctl dispatch dpms off'"
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
        wallpaper = ${toString vars.mainMonitor},~/.local/wallchange/mywallpaper.jpg
        wallpaper = ${toString vars.secondMonitor},~/.local/wallchange/mywallpaper.jpg
        wallpaper = ${toString vars.thirdMonitor},~/.local/wallchange/mywallpaper.jpg
      '';
    };
  };
}
