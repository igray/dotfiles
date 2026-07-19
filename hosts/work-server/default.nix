{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../nixos/common.nix
    ../../nixos/work-server.nix
    ../../nixos/assistant.nix
    ../../nixos/devenv-cpats.nix
  ];

  boot.initrd.luks.devices."luks-c6add9c8-7870-4f49-bc27-bd70fcea58c3".crypttabExtraOpts = [
    "tpm2-device=auto"
  ];
}
