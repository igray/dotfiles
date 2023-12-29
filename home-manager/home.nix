{ pkgs, vars, ... }:
let
  homeDirectory = "/home/${vars.username}";
in
{
  imports = [
    ./ags.nix
    ./alacritty.nix
    ./browser.nix
    ./dconf.nix
    ./git.nix
    ./hyprland.nix
    ./lf.nix
    ./neovim.nix
    ./packages.nix
    ./sh.nix
    ./starship.nix
    ./theme.nix
    ./tmux.nix
    ./wallpaper.nix
    ./wezterm.nix
    ./mimelist.nix
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
      QT_XCB_GL_INTEGRATION = "none"; # kde-connect
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
    "file://${homeDirectory}/Projects"
    "file://${homeDirectory}/Vault"
    "file://${homeDirectory}/Vault/School"
    "file://${homeDirectory}/.config Config"
    "file://${homeDirectory}/.local/share Local"
  ];

  services = {
    kdeconnect = {
      enable = true;
      indicator = true;
    };
  };

  programs.home-manager.enable = true;
  xdg.enable = true;
  home.stateVersion = "21.11";
}
