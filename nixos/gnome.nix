{ config, pkgs, ... }:
{
  environment = {
    sessionVariables = {
      NAUTILUS_EXTENSION_DIR = "${config.system.path}/lib/nautilus/extensions-4";
    };

    pathsToLink = [
      "/share/nautilus-python/extensions"
    ];

    systemPackages = with pkgs; [
      gnome-extension-manager
      nautilus-open-any-terminal
      qogir-icon-theme
      gnome.nautilus-python
    ];

    gnome.excludePackages = (with pkgs; [
      gnome-text-editor
      gnome-console
      gnome-photos
      gnome-tour
      gnome-connections
    ]) ++ (with pkgs.gnome; [
      cheese # webcam tool
      gnome-music
      gedit # text editor
      epiphany # web browser
      geary # email reader
      gnome-characters
      totem # video player
      tali # poker game
      iagno # go game
      hitori # sudoku game
      atomix # puzzle game
      yelp # Help view
      gnome-contacts
      gnome-initial-setup
      gnome-shell-extensions
      gnome-maps
    ]);
  };

  services.xserver = {
    displayManager.gdm.enable = true;
    desktopManager.gnome = {
      enable = true;
      extraGSettingsOverridePackages = [
        pkgs.nautilus-open-any-terminal
      ];
    };
  };

  programs.dconf.profiles = {
    gdm.databases = [{
      settings = {
        "org/gnome/desktop/interface" = {
          cursor-theme = "Qogir";
        };
      };
    }];
  };
}
