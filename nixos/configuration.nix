{ pkgs, vars, ... }:
{

  imports = [
    ./hardware-configuration.nix
    ./audio.nix
    ./fonts.nix
    ./desktop.nix
    ./laptop.nix
    ./locale.nix
    ./restic.nix
    ./wallpaper.nix
  ];

  # nix
  documentation.nixos.enable = false;
  nixpkgs.config.allowUnfree = true;
  nix = {
    settings = {
      download-buffer-size = 567108864;
      experimental-features = "nix-command flakes";
      auto-optimise-store = true;
      trusted-users = [
        "root"
        vars.username
      ];
    };
    gc = {
      # Garbage Collection
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
      persistent = true;
    };
  };

  # virtualisation
  virtualisation = {
    docker.enable = true;
    # podman.enable = true;
    libvirtd = {
      enable = true;
      qemu.vhostUserPackages = with pkgs; [ virtiofsd ];
    };
    waydroid.enable = true;
  };

  programs = {
    adb.enable = true;
    dconf.enable = true;
    fish.enable = true;
    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
    };
    virt-manager.enable = true;
  };

  # packages
  environment.systemPackages = with pkgs; [
    cachix
    git
    home-manager
    libva-utils
    systemctl-tui
    wget
  ];

  # services
  services = {
    xserver = {
      enable = true;
      excludePackages = [ pkgs.xterm ];
    };
    printing.enable = true;
    flatpak.enable = true;
    envfs.enable = true;
    fwupd.enable = true;
    openssh.enable = true;
    avahi = {
      enable = true;
      nssmdns4 = true;
    };
  };

  # logind
  services.logind.extraConfig = ''
    HandlePowerKey=ignore
    HandleLidSwitch=suspend
    HandleLidSwitchExternalPower=ignore
  '';

  # user
  users.users.${vars.username} = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [
      "adbusers"
      "audio"
      "camera"
      "docker"
      "libvirtd"
      "lp"
      "networkmanager"
      "scanner"
      "video"
      "wheel"
    ];
  };

  # network
  networking = {
    firewall.allowedTCPPorts = [
      443
      8443
      80
      8080
    ];
    hostName = "laptop";
    networkmanager.enable = true;
    hosts = {
      "127.0.0.1" = [
        "lvh.me"
        "app.lvh.me"
        "cpats.click"
      ];
    };
  };

  security = {
    rtkit.enable = true;
  };

  # bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # simple-scan
  hardware.sane = {
    enable = true;
    extraBackends = [ pkgs.hplipWithPlugin ];
  };

  # bootloader
  boot = {
    # Boot Options
    tmp.cleanOnBoot = true;
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 5;
      };
      efi.canTouchEfiVariables = true;
      timeout = 1;
    };
  };

  system.stateVersion = "23.05";
}
