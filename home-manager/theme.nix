{ pkgs, ... }:
let
  gtk-theme = "adw-gtk3-dark";
in
{
  home = {
    packages = with pkgs; [
      adw-gtk3
      font-awesome
      joypixels
    ];
  };
  gtk = {
    enable = true;
    font.name = "Ubuntu Nerd Font";
    gtk4.theme = null;
    theme.name = gtk-theme;
  };

  qt = {
    enable = true;
    platformTheme.name = "kde";
  };

  # Ghostty >= 1.3.0 honours this GTK setting for middle-click paste from the
  # primary selection. It defaults to false outside GNOME, so COSMIC leaves
  # middle-click paste silently disabled.
  dconf.settings."org/gnome/desktop/interface".gtk-enable-primary-paste = true;
}
