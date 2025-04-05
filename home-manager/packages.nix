{
  inputs,
  pkgs,
  unstable,
  ...
}:
{
  home.packages = with pkgs; [
    # gui
    (mpv.override { scripts = [ mpvScripts.mpris ]; })
    annotator
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
    inkscape
    unstable.joplin-desktop
    libreoffice-fresh
    resources
    simple-scan
    slack
    spotify
    sshfs
    tidal-hifi
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
    curl
    devenv
    fd
    fzf
    glib
    glow
    inotify-tools
    jq
    killall
    lazygit
    libnotify
    mermaid-cli
    pciutils
    qmk
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
    xdg-utils # Open files
  ];
}
