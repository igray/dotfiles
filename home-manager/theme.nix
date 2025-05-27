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
    sessionVariables = {
      GTK_THEME = gtk-theme;
    };
  };

  gtk = {
    enable = true;
    font.name = "Ubuntu Nerd Font";
    theme.name = gtk-theme;
  };

  qt = {
    enable = true;
    platformTheme.name = "kde";
  };
}
