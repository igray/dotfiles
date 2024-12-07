{ pkgs, vars, ... }:
let
  homeDirectory = "/home/${vars.username}";
in
{
  imports = [
    ./alacritty.nix
    ./browser.nix
    ./desktop.nix
    ./git.nix
    ./lf.nix
    ./nixvim.nix
    ./packages.nix
    ./sh.nix
    ./starship.nix
    ./theme.nix
    ./tmux.nix
    ./wallpaper.nix
    ./wezterm.nix
  ];

  news.display = "show";

  targets.genericLinux.enable = true;

  nix = {
    package = pkgs.nix;
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      warn-dirty = false;
    };
  };

  home = {
    inherit homeDirectory;

    username = vars.username;
    sessionVariables = {
      NIXPKGS_ALLOW_UNFREE = "1";
      SHELL = "${pkgs.fish}/bin/fish";
      BAT_THEME = "base16";
    };

    sessionPath = [
      "$HOME/.local/bin"
    ];
  };

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

  programs.home-manager.enable = true;
  xdg.enable = true;
  home.stateVersion = "21.11";
}
