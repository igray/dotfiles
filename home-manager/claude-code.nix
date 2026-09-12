{ ... }:
{
  # `package` defaults to `pkgs.claude-code`, which overlays/claude-code.nix
  # replaces; setting it here drops the version pin and the python3 wrapper.
  programs.claude-code.enable = true;
}
