{ pkgs, unstable, ... }:
{
  home.packages = with pkgs; with nodePackages_latest; with gnome; [
    # gui
    (mpv.override { scripts = [mpvScripts.mpris]; })
    authenticator
    calibre
    d-spy
    dconf-editor
    discord
    foliate
    font-manager
    gimp
    gnome-characters
    icon-library
    libreoffice-fresh
    simple-scan
    slack
    spotify
    unstable.logseq
    vlc
    # zoom-us

    # tools
    acpi
    bat
    btop
    fd
    fzf
    glib
    glow
    inotify-tools
    jq
    killall
    libnotify
    pciutils
    ripgrep
    s3fs
    socat
    unzip
    usbutils
    wget
    unzip
    zip

    # hyprland
    brightnessctl
    gammastep       # Nightlight
    grim            # Grab Images
    hyprpaper       # Background manager
    hyprpicker
    imagemagick
    pavucontrol
    slurp
    swappy
    swayidle        # Idle Daemon
    wf-recorder
    wl-clipboard
    wl-gammactl

    # original config dependencies
    xdg-utils       # Open files

    # ags
    bun
    dart-sass
  ];
}
