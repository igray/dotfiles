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
    emote
    foliate
    font-manager
    gimp
    gnome-characters
    icon-library
    inkscape
    unstable.joplin-desktop
    libreoffice-fresh
    simple-scan
    slack
    spotify
    tidal-hifi
    unstable.logseq
    unstable.zed-editor
    vlc
    # zoom-us

    # tools
    acpi
    bat
    btop
    unstable.devenv
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
    # unstable.hyprpaper       # Background manager
    hyprpicker
    image-roll
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
