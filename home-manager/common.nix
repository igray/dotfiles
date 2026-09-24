{ pkgs, vars, ... }:
let
  homeDirectory = "/home/${vars.username}";
in
{
  imports = [
    ./antigravity.nix
    ./claude-code.nix
    ./git.nix
    ./glow.nix
    ./herdr.nix
    ./lf.nix
    ./mpv.nix
    ./nixvim.nix
    ./opencode.nix
    ./packages.nix
    ./rclone.nix
    ./sh.nix
    ./sops.nix
    ./starship.nix
    ./tmux.nix
    ./worktrunk.nix
    ./zed.nix
    ./zk.nix
  ];

  news.display = "show";
  targets.genericLinux.enable = true;

  nix = {
    gc = {
      automatic = true;
      options = "--delete-older-than 30d";
      persistent = true;
    };
    package = pkgs.nix;
    settings = {
      download-buffer-size = 567108864;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
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

  # See systemd-user.conf(5): cap SIGTERM->SIGKILL wait so long-lived terminal
  # sessions don't stall shutdown for the full 90s default.
  systemd.user.settings.Manager.DefaultTimeoutStopSec = "15s";

  programs.home-manager.enable = true;
  xdg.enable = true;
  home.stateVersion = "21.11";
}
