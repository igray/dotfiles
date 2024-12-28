{ pkgs, unstable, ... }:
{
  home.packages = with pkgs; with nodePackages_latest; [
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
    gnome-calculator
    gnome-characters
    icon-library
    image-roll
    inkscape
    unstable.joplin-desktop
    unstable.libreoffice-fresh
    simple-scan
    slack
    spotify
    tidal-hifi
    unstable.logseq
    unstable.zed-editor
    vlc
    wf-recorder
    wl-clipboard

    # tools
    acpi
    atac
    bat
    bottom
    chafa
    csvlens
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
    repgrep
    ripgrep
    s3fs
    socat
    unzip
    usbutils
    wget
    unzip
    zip

    # original config dependencies
    xdg-utils       # Open files
  ];
}
