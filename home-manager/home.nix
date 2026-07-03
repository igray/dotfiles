{ pkgs, vars, ... }:
let
  homeDirectory = "/home/${vars.username}";
in
{
  imports = [
    ./alacritty.nix
    ./android.nix
    ./browser.nix
    ./claude-desktop.nix
    ./desktop.nix
    ./git.nix
    ./ghostty.nix
    ./glow.nix
    ./lf.nix
    ./nixvim.nix
    ./packages.nix
    ./rclone.nix
    ./sh.nix
    ./sops.nix
    ./starship.nix
    ./theme.nix
    ./tmux.nix
    ./wallpaper.nix
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

  # Cap how long the user service manager waits for a unit/scope to stop after
  # SIGTERM before escalating to SIGKILL. Default is 90s; long-lived terminal
  # sessions (Claude Code + its python MCP/tool subprocesses) routinely ignore
  # SIGTERM and burn the full 90s at reboot, stalling shutdown. 15s still gives
  # well-behaved apps time to save state. Only affects user units, not system
  # services. See systemd-user.conf(5).
  systemd.user.settings.Manager.DefaultTimeoutStopSec = "15s";

  programs.home-manager.enable = true;
  xdg.enable = true;
  home.stateVersion = "21.11";
}
