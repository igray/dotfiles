{
  pkgs,
  vars,
  lib,
  ...
}:
{
  imports = [
    ./locale.nix
  ];

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
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
      persistent = true;
    };
  };

  programs = {
    fish.enable = true;
    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
    };
    nix-ld = {
      enable = true;
      libraries = with pkgs; [
        stdenv.cc.cc
        zlib
        openssl
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    cachix
    git
    home-manager
    systemctl-tui
    wget
  ];

  services = {
    envfs.enable = true;
    fwupd.enable = true;
    openssh.enable = true;
    avahi = {
      enable = true;
      nssmdns4 = true;
    };
  };

  users.users.${vars.username} = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  networking = {
    enableIPv6 = false;
    networkmanager.enable = true;
  };

  # NetworkManager owns the interfaces, so systemd-networkd has no use.
  systemd.suppressedSystemUnits = [
    "systemd-networkd.service"
    "systemd-networkd.socket"
    "systemd-networkd-wait-online.service"
  ];

  # ...but work-server's initrd runs networkd for the remote LUKS unlock, and
  # /run survives switch-root, so /run/systemd/netif/state arrives in the booted
  # system frozen at OPER_STATE=off. With networkd suppressed nothing ever
  # updates it, and timesyncd believes it is offline forever (never sends a
  # single packet). Drop the stale file before timesyncd reads it; with no
  # networkd state at all it falls back to assuming the network is up.
  # No-op on hosts without initrd networking.
  systemd.services.systemd-timesyncd.serviceConfig.ExecStartPre =
    "+${pkgs.coreutils}/bin/rm -f /run/systemd/netif/state";

  boot = {
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

  # mkDefault so a host (e.g. the freshly-installed server) can override it.
  system.stateVersion = lib.mkDefault "23.05";
}
