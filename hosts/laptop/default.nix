{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../nixos/common.nix
    ../../nixos/laptop.nix
    ../../nixos/desktop.nix
    ../../nixos/audio.nix
    ../../nixos/fonts.nix
    ../../nixos/wallpaper.nix
    ../../nixos/restic.nix
    ../../nixos/amd-ai.nix
    ../../nixos/wireguard.nix
  ];

  # GUI/VAAPI video-acceleration debug tools (laptop-only; common.nix omits VAAPI).
  environment.systemPackages = with pkgs; [ libva-utils ];

  networking = {
    hostName = "laptop";
    firewall.allowedTCPPorts = [
      443
      8443
      80
      8080
    ];
    hosts = {
      "127.0.0.1" = [
        "lvh.me"
        "app.lvh.me"
        "cpats.click"
      ];
    };
  };

  # virtualisation (laptop dev environment)
  virtualisation = {
    docker.enable = true;
    libvirtd = {
      enable = true;
      qemu.vhostUserPackages = with pkgs; [ virtiofsd ];
    };
    waydroid.enable = true;
  };

  programs = {
    appimage = {
      enable = true;
      binfmt = true;
    };
    dconf.enable = true;
    virt-manager.enable = true;
  };

  # GUI-related system services
  services = {
    xserver = {
      enable = true;
      excludePackages = [ pkgs.xterm ];
    };
    printing.enable = true;
    flatpak.enable = true;
  };

  # laptop lid/power behaviour
  services.logind.settings.Login = {
    HandlePowerKey = "ignore";
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "ignore";
  };

  # laptop user gets the desktop/dev groups
  users.users.igray.extraGroups = [
    "adbusers"
    "audio"
    "camera"
    "docker"
    "input"
    "libvirtd"
    "lp"
    "render" # GPU/NPU compute access for amd-ai.nix (lemonade, ROCm)
    "scanner"
    "video"
  ];

  security.rtkit.enable = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  hardware.sane = {
    enable = true;
    extraBackends = [ pkgs.hplipWithPlugin ];
  };
}
