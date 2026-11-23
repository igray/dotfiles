{ pkgs, ... }:
{
  imports = [
    ./common.nix
  ];

  # sshd runs ~/.ssh/rc on every login, including herdr's bridge connections.
  # It leaves dead sockets in ~/.ssh/agent, so only ssh-add can tell a live link.
  home.file.".ssh/rc".text = ''
    if [ -S "$SSH_AUTH_SOCK" ]; then
      SSH_AUTH_SOCK="$HOME/.ssh/auth_sock" ${pkgs.openssh}/bin/ssh-add -l >/dev/null 2>&1
      if [ $? -eq 2 ]; then
        ln -sfn "$SSH_AUTH_SOCK" "$HOME/.ssh/auth_sock"
      fi
    fi
  '';

  # HERDR_ENV marks terminal herdr panes, HC_TERMINAL_ID herdr-desktop ones.
  programs.fish.shellInit = ''
    if set -q HERDR_ENV; or set -q HC_TERMINAL_ID
      set -gx SSH_AUTH_SOCK "$HOME/.ssh/auth_sock"
    end
  '';
}
