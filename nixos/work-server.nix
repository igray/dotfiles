{ ... }:
{
  networking.hostName = "work-server";

  # systemd-based initrd — required for TPM2-backed LUKS auto-unlock (Task 8).
  boot.initrd.systemd.enable = true;

  # Headless box in a case: no lid, ignore the power key so a stray press
  # can't suspend it.
  services.logind.settings.Login = {
    HandlePowerKey = "ignore";
    HandleLidSwitch = "ignore";
  };

  # Containers for self-hosted services; no libvirt/waydroid/GUI.
  virtualisation.docker.enable = true;

  users.users.igray.extraGroups = [ "docker" ];

  # Fresh install: set to the release you install from (confirm in Task 8).
  system.stateVersion = "25.05";
}
