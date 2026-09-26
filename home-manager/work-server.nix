{ ... }:
{
  imports = [
    ./common.nix
  ];

  # sshd runs ~/.ssh/rc on every login, including herdr's bridge connections.
  home.file.".ssh/rc".text = ''
    if [ -S "$SSH_AUTH_SOCK" ]; then
      ln -sfn "$SSH_AUTH_SOCK" "$HOME/.ssh/auth_sock"
    fi
  '';

  programs.fish.shellInit = ''
    if set -q HERDR_ENV
      set -gx SSH_AUTH_SOCK "$HOME/.ssh/auth_sock"
    end
  '';
}
