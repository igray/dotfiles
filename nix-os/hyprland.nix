{ inputs, pkgs, ... }:
{
  services.xserver = {
    displayManager.startx.enable = true;
  };

  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    xwayland.enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
  };

  security = {
    polkit.enable = true;
  };

  environment.systemPackages = with pkgs.gnome; [
    adwaita-icon-theme
    nautilus
    gnome-calendar
    gnome-boxes
    gnome-system-monitor
    gnome-control-center
    gnome-weather
    gnome-calculator
    gnome-software # for flatpak

    # original config dependencies
    pkgs.cliphist        # Search clipboard
    pkgs.gammastep       # Nightlight
    pkgs.grim            # Grab Images
    pkgs.hyprpaper       # Background manager
    pkgs.slurp           # Region Selector
    pkgs.swappy          # Snapshot Editor
    pkgs.swayidle        # Idle Daemon
    pkgs.swaylock        # Lock Screen
    pkgs.wl-clipboard    # Clipboard
    pkgs.wlr-randr       # Monitor Settings
    pkgs.udiskie         # Removable drive automount
    pkgs.xdg-utils       # Open files
    pkgs.eww-wayland         # Widgets
    pkgs.jq                  # JSON Processor
    pkgs.socat               # Data Transfer
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
    accounts-daemon.enable = true;
    gnome = {
      evolution-data-server.enable = true;
      glib-networking.enable = true;
      gnome-keyring.enable = true;
      gnome-online-accounts.enable = true;
    };
  };
}
