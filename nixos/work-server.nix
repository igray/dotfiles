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

  users.users.igray.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGa2Fl7BrbkjzF9BxAODhMfHSQLCt/K41MkPOi8VZCoL igray@igray-laptop"
  ];
  services.openssh.settings.PasswordAuthentication = false;

  # The old SSD carries its existing 23.05 install over unchanged, so keep the
  # original stateVersion — raising it on an existing system can silently change
  # stateful service defaults. (Only set this to the install-media release for a
  # genuinely fresh server install.)
  system.stateVersion = "23.05";
}
