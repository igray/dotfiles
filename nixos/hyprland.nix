{ pkgs, ... }:
{
  services.xserver = {
    displayManager.gdm = {
      enable = true;
      autoSuspend = false;
    };
    displayManager.startx.enable = true;
  };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
  };

  security = {
    polkit.enable = true;
    pam.services.gdm.enableGnomeKeyring = true;
    pam.services.swaylock = {};
  };

  environment.systemPackages = with pkgs.gnome; [
    adwaita-icon-theme
    baobab
    gnome-boxes
    gnome-calculator
    gnome-calendar
    gnome-clocks
    gnome-control-center
    gnome-software # for flatpak
    gnome-system-monitor
    gnome-weather
    nautilus
    pkgs.loupe
    pkgs.nwg-displays
    pkgs.wlr-randr
  ];

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

  services = {
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
      gnome-online-accounts.enable = true;
    };
  };
}
