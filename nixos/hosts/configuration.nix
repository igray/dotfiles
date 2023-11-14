#
#  Main system configuration. More information available in configuration.nix(5) man page.
#
#  flake.nix
#   ├─ ./hosts
#   │   ├─ default.nix
#   │   └─ configuration.nix *
#   └─ ./modules
#       ├─ ./desktops
#       │   └─ default.nix
#       ├─ ./editors
#       │   └─ default.nix
#       ├─ ./hardware
#       │   └─ default.nix
#       ├─ ./programs
#       │   └─ default.nix
#       ├─ ./services
#       │   └─ default.nix
#       ├─ ./shell
#       │   └─ default.nix
#       └─ ./theming
#           └─ default.nix
#

{ config, lib, pkgs, unstable, inputs, vars, ... }:

{
  imports = ( import ../modules/desktops ++
              import ../modules/editors ++
              import ../modules/hardware ++
              import ../modules/programs ++
              import ../modules/services ++
              import ../modules/shell ++
              import ../modules/theming );

  users.users.${vars.user} = {              # System User
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "audio" "camera" "networkmanager" "lp" "scanner" ];
  };

  time.timeZone = "America/Chicago";        # Time zone and Internationalisation
  i18n = {
    defaultLocale = "en_US.UTF-8";
  };

  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  security = {
    rtkit.enable = true;
    polkit.enable = true;
    sudo.wheelNeedsPassword = false;
  };

  fonts.fonts = with pkgs; [                # Fonts
    cantarell-fonts                         # NixOS
    carlito                                 # NixOS
    vegur                                   # NixOS
    source-code-pro
    jetbrains-mono
    font-awesome                            # Icons
    corefonts                               # MS
    (nerdfonts.override {                   # Nerdfont Icons override
      fonts = [
        "JetBrainsMono"
      ];
    })
  ];

  environment = {
    variables = {                           # Environment Variables
      TERMINAL = "${vars.terminal}";
      EDITOR = "${vars.editor}";
      VISUAL = "${vars.editor}";
    };
    systemPackages = with pkgs; [           # System-Wide Packages
      # Terminal
      bat               # Pager
      btop              # Resource Manager
      coreutils         # GNU Utilities
      git               # Version Control
      killall           # Process Killer
      nano              # Text Editor
      nix-tree          # Browse Nix Store
      pciutils          # Manage PCI
      ranger            # File Manager
      nodejs_20         # Neovim/Mason
      ripgrep           # Neovim/Telescope
      fd                # Neovim/Telescope
      gcc               # Neovim/Treesitter
      tldr              # Helper
      stow              # Until config is integrated here
      usbutils          # Manage USB
      wget              # Retriever

      # Video/Audio
      alsa-utils        # Audio Control
      feh               # Image Viewer
      mpv               # Media Player
      pavucontrol       # Audio Control
      pipewire          # Audio Server/Control
      pulseaudio        # Audio Server/Control
      vlc               # Media Player
      vulkan-tools      # Troubleshoot GL
      stremio           # Media Streamer

      # Apps
      appimage-run      # Runs AppImages on NixOS
      authenticator     # 2FA
      gcr               # Secrets prompter?
      openssl           # Keygen
      polkit_gnome      # PW Prompt
      remmina           # XRDP & VNC Client
      slack             # Talky
      zoom-us           # Work calls

      # File Management
      gnome.file-roller # Archive Manager
      okular            # PDF Viewer
      pcmanfm           # File Browser
      p7zip             # Zip Encryption
      rsync             # Syncer - $ rsync -r dir1/ dir2/
      unzip             # Zip Files
      unrar             # Rar Files
      zip               # Zip

      # Other Packages Found @
      # - ./<host>/default.nix
      # - ../modules
    ] ++
    (with unstable; [
      # Apps
      firefox           # Browser
      logseq            # Notes
    ]);
  };

  programs = {
    dconf.enable = true;
  };

  services = {
    printing = {                            # CUPS
      enable = true;
    };
    pipewire = {                            # Sound
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      jack.enable = true;
    };
    openssh = {                             # SSH
      enable = true;
      allowSFTP = true;                     # SFTP
      extraConfig = ''
        HostKeyAlgorithms +ssh-rsa
      '';
    };
    envfs = {
      enable = true;
    };
  };

  flatpak.enable = false;                    # Enable Flatpak (see module options)

  nix = {                                   # Nix Package Manager Settings
    settings = {
      auto-optimise-store = true;
      trusted-users = [ "root" vars.user ];
    };
    gc = {                                  # Garbage Collection
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 2d";
    };
    package = pkgs.nixVersions.unstable;    # Enable Flakes
    registry.nixpkgs.flake = inputs.nixpkgs;
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs          = true
      keep-derivations      = true
    '';
  };
  nixpkgs = {
    config = {
       allowUnfree = true;                  # Allow Proprietary Software.
    };
  };
  nixpkgs.config.permittedInsecurePackages = [
    "electron-24.8.6"
  ];

  system = {                                # NixOS Settings
    #autoUpgrade = {                        # Allow Auto Update (not useful in flakes)
    #  enable = true;
    #  channel = "https://nixos.org/channels/nixos-unstable";
    #};
    stateVersion = "22.05";
  };

  home-manager.users.${vars.user} = {       # Home-Manager Settings
    home = {
      stateVersion = "22.05";
    };

    programs = {
      home-manager.enable = true;
    };
  };
}
