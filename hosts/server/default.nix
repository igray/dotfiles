{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../nixos/common.nix
    ../../nixos/server.nix
    ../../nixos/server-web.nix
    ../../nixos/server-media.nix
    ../../nixos/server-shares.nix
    ../../nixos/server-backup.nix
  ];
}
