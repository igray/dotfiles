{ pkgs, ... }:
{
  services = {
    desktopManager.cosmic.enable = true;
    displayManager.cosmic-greeter.enable = true;
    xserver = {
      displayManager.startx.enable = true;
    };
    gvfs.enable = true;
    devmon.enable = true;
    udisks2.enable = true;
    upower.enable = true;
    power-profiles-daemon.enable = true;
    accounts-daemon.enable = true;
    gnome = {
      evolution-data-server.enable = true;
      glib-networking.enable = true;
      gnome-keyring.enable = true;
    };
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  security = {
    polkit.enable = true;
    pam.services = {
      gdm.enableGnomeKeyring = true;
      cosmic-greeter.enableGnomeKeyring = true;
      swaylock = {};
    };
  };

  environment = {
    systemPackages = with pkgs; [
      xdg-desktop-portal-gtk
    ];
    sessionVariables = {
      AWT_TOOLKIT = "MToolkit";
      COSMIC_DISABLE_DIRECT_SCANOUT = "1";
      GDK_BACKEND = "wayland";
      MOZ_ENABLE_WAYLAND = "1";
      NIXOS_OZONE_WL = "1";
      QT_QPA_PLATFORM = "wayland";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/keyring/ssh";
      WLR_NO_HARDWARE_CURSORS = "1";
      _JAVA_AWT_WM_NONREPARENTING = "1";
    };
  };

  systemd = {
    user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };
}
