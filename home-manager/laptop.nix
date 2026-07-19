{ vars, ... }:
let
  homeDirectory = "/home/${vars.username}";
in
{
  imports = [
    ./common.nix
    ./alacritty.nix
    ./android.nix
    ./browser.nix
    ./claude-desktop.nix
    ./ghostty.nix
    ./theme.nix
    ./wallpaper.nix
  ];

  gtk.gtk3.bookmarks = [
    "file://${homeDirectory}/Documents"
    "file://${homeDirectory}/Music"
    "file://${homeDirectory}/Pictures"
    "file://${homeDirectory}/Videos"
    "file://${homeDirectory}/Downloads"
    "file://${homeDirectory}/Desktop"
    "file://${homeDirectory}/Work"
    "file://${homeDirectory}/Documents/Finance/Invoices Invoices"
    "file://${homeDirectory}/.config Config"
    "file://${homeDirectory}/.local/share Local"
  ];
}
