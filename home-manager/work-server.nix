{ pkgs, ... }:
let
  # The oldest live socket wins, so a short-lived login can't take the link
  # down with it when it exits.
  refreshAuthSock = pkgs.writeShellApplication {
    name = "refresh-ssh-auth-sock";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.openssh
    ];
    excludeShellChecks = [ "SC2012" ];
    text = ''
      link="$HOME/.ssh/auth_sock"
      sockets="$HOME/.ssh/agent"

      alive() {
        local status=0
        SSH_AUTH_SOCK="$1" ssh-add -l > /dev/null 2>&1 || status=$?
        [ "$status" -ne 2 ]
      }

      if alive "$link"; then
        exit 0
      fi
      mapfile -t oldest_first < <(ls -tr "$sockets" 2> /dev/null)
      for sock in "''${oldest_first[@]}"; do
        if alive "$sockets/$sock"; then
          ln -sfn "$sockets/$sock" "$link"
          exit 0
        fi
      done
    '';
  };
  refresh = "${refreshAuthSock}/bin/refresh-ssh-auth-sock";
in
{
  imports = [
    ./common.nix
  ];

  # sshd runs ~/.ssh/rc on every login, including herdr's bridge connections.
  home.file.".ssh/rc".text = ''
    ${refresh}
  '';

  # HERDR_ENV marks terminal herdr panes, HC_TERMINAL_ID herdr-desktop ones.
  programs.fish.shellInit = ''
    if set -q HERDR_ENV; or set -q HC_TERMINAL_ID
      set -gx SSH_AUTH_SOCK "$HOME/.ssh/auth_sock"
      function __refresh_ssh_auth_sock --on-event fish_preexec
        ${refresh}
      end
    end
  '';
}
