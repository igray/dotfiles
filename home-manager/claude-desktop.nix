{ pkgs, ... }:
{
  xdg.configFile."Claude/claude_desktop_linux_config.json".source =
    (pkgs.formats.json { }).generate "claude_desktop_linux_config.json" {
      preferences.coworkBwrapMounts.additionalROBinds = [
        "/nix/store"
        "/.host-etc"
      ];
    };
}
