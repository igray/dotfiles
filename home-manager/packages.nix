{
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
    unstable.calibre
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
    obs-studio
    resources
    simple-scan
    unstable.shattered-pixel-dungeon
    slack
    spotify
    sshfs
    tidal-hifi
    vlc
    warp-terminal
    wf-recorder
    wl-clipboard
    unstable.zed-editor
    unstable.zoom-us

    # tools
    acpi
    atac
    bat
    bottom
    chafa
    unstable.claude-code
    csvlens
    curl
    devenv
    fd
    fzf
    unstable.gemini-cli
    glib
    glow
    inotify-tools
    jq
    killall
    lazygit
    libnotify
    mermaid-cli
    pciutils
    powertop
    qmk
    repgrep
    ripgrep
    s3fs
    slides
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
