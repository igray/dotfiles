# PLACEHOLDER — replace with `nixos-generate-config` output on the server board (Task 8).
{ lib, modulesPath, ... }:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];
  boot.loader.grub.enable = lib.mkDefault false;
  # No fileSystems / luks yet; the real disk layout is generated in Task 8.
}
