{
  config,
  lib,
  pkgs,
  ...
}:
let
  lan = "192.168.86.0/24";

  composeProject = dir: {
    description = "docker compose project in ${dir}";
    after = [
      "docker.service"
      "network-online.target"
    ];
    requires = [ "docker.service" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    unitConfig.ConditionPathExists = "${dir}/docker-compose.yml";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      WorkingDirectory = dir;
      ExecStart = "${lib.getExe config.virtualisation.docker.package} compose up -d";
      ExecStop = "${lib.getExe config.virtualisation.docker.package} compose down --timeout 30";
    };
  };
in
{
  networking.hostName = "server";
  networking.enableIPv6 = lib.mkForce true;

  # Only 80/443 are reachable from outside; the LAN keeps the unrestricted
  # access it had before, which music-assistant's dynamic ports depend on.
  networking.firewall = {
    allowedTCPPorts = [
      80
      443
    ];
    extraCommands = ''
      iptables -I nixos-fw 1 -s ${lan} -j nixos-fw-accept
      ip6tables -I nixos-fw 1 -s fe80::/10 -j nixos-fw-accept
      ip6tables -I nixos-fw 1 -s fc00::/7 -j nixos-fw-accept
    '';
  };

  boot.swraid = {
    enable = true;
    mdadmConf = ''
      MAILADDR root
      ARRAY /dev/md/mediaraid metadata=1.2 UUID=51adf3d9:c34d2b43:922a800f:2c01cafb
      ARRAY /dev/md/0 metadata=1.2 UUID=fcdeacfa:042443b2:a07c1b20:5c997485
    '';
  };

  fileSystems."/media/media" = {
    device = "/dev/disk/by-uuid/da606cc3-015a-494c-838c-7424c9bfe988";
    fsType = "ext4";
    options = [ "nofail" ];
  };

  fileSystems."/media/backup" = {
    device = "/dev/disk/by-uuid/069a426b-23a1-4c3f-9362-062b892cea9e";
    fsType = "ext4";
    options = [ "nofail" ];
  };

  systemd.services.raid-check = {
    description = "Scrub the md arrays";
    startAt = "Sun *-*-1..7 03:00";
    serviceConfig.Type = "oneshot";
    script = ''
      for action in /sys/block/md*/md/sync_action; do
        echo check > "$action"
      done
    '';
  };

  services.fstrim.enable = true;
  services.atd.enable = true;
  zramSwap.enable = true;

  # The wireguard container bind-mounts /lib/modules to modprobe for itself,
  # which NixOS does not have, so the module has to be loaded already.
  boot.kernelModules = [
    "wireguard"
    "tun"
    "nct6775"
  ];

  virtualisation.docker.enable = true;

  # Containers keep their state under /media/media and docker restarts them
  # itself, so without the mount they would write into the bare mountpoint.
  systemd.services.docker.unitConfig.RequiresMountsFor = [ "/media/media" ];

  systemd.services.compose-docker = composeProject "/opt/docker";
  systemd.services.compose-immich = composeProject "/opt/immich-app";

  users.groups.media.gid = 1001;

  users.users.igray = {
    uid = 1000;
    extraGroups = [
      "docker"
      "media"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBX3vVi4fisgt7T59SoBXcJB9CdjShepBtk7PP7wdKnA igray78756@gmail.com"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGa2Fl7BrbkjzF9BxAODhMfHSQLCt/K41MkPOi8VZCoL igray@igray-laptop"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBIGISD8JBBPBbaSfarQmn7NDDinX75UN+D3Yalb7CXV igray@penguin"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP+/NN+Vepw8KFIeTaaFAFgCo03t5MZpYUN6Ma8etG1k igray@restic"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPbszgajEfcZwFm8SnFSOcy4LaXRtrELTnHX+vSUYr80 igray@laptop"
    ];
  };

  services.openssh.settings = {
    PasswordAuthentication = false;
    AllowUsers = [ "igray" ];
  };

  programs.mosh.enable = true;

  environment.systemPackages = with pkgs; [
    _7zz
    aria2
    dmidecode
    dos2unix
    hdparm
    htop
    iotop
    lm_sensors
    mdadm
    nnn
    pciutils
    restic
    rsync
    smartmontools
    speedtest-cli
    streamlink
    tmux
    unzip
    usbutils
  ];

  system.stateVersion = "26.11";
}
