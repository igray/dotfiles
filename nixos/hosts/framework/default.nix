#
#  Specific system configuration settings for work
#
#  flake.nix
#   ├─ ./hosts
#   │   ├─ default.nix
#   │   └─ ./work
#   │        ├─ default.nix *
#   │        └─ hardware-configuration.nix
#   └─ ./modules
#       ├─ ./desktops
#       │   ├─ hyprland.nix
#       │   └─ ./virtualisation
#       │       └─ default.nix
#       └─ ./hardware
#           └─ ./work
#               └─ default.nix
#

{ pkgs, vars, ... }:

{
  imports = [ ./hardware-configuration.nix ] ++
            ( import ../../modules/desktops/virtualisation ) ++
            ( import ../../modules/hardware/work );

  boot = {                                      # Boot Options
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 5;
      };
      efi.canTouchEfiVariables = true;
      timeout = 1;
    };
    kernelPackages = pkgs.linuxPackages_latest;
    initrd.kernelModules = [ "amdgpu" ];        # Video Drivers
  };

  laptop.enable = true;                         # Laptop modules
  hyprland.enable = true;                       # Window manager

  hardware = {
    cpu = {
      amd = {
        updateMicrocode = true;
      };
    };
    opengl = {                                  # Hardware Accelerated Video
      enable = true;
      driSupport = true;
      extraPackages = with pkgs; [
        rocm-opencl-icd
        rocm-opencl-runtime
        amdvlk
      ];
    };
    sane = {                                    # Scanning
      enable = true;
      extraBackends = [ pkgs.sane-airscan ];
    };
  };

  networking = {
    hostName = "laptop";
    networkmanager.enable = true;
  };

  environment = {
    systemPackages = with pkgs; [               # System Wide Packages
      ansible           # Automation
      nil               # LSP
      onlyoffice-bin    # Office
      rclone            # Gdrive ($ rclone config | rclone mount --daemon gdrive: <mount> | fusermount -u <mount>)
      simple-scan       # Scanning
      sshpass           # Ansible dependency
      wacomtablet       # Tablet
      wdisplays         # Display Configurator
    ];
  };

  programs.light.enable = true;                 # Monitor Brightness

  systemd.services.NetworkManager-wait-online.enable = false;
}
