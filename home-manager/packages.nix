{
  pkgs,
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
    google-chrome
    icon-library
    inkscape
    kdePackages.kdenlive
    libreoffice-fresh
    obs-studio
    resources
    simple-scan
    shattered-pixel-dungeon
    slack
    spotify
    sshfs
    tidal-hifi
    vlc
    warp-terminal
    wf-recorder
    wl-clipboard
    # zed-editor
    zoom-us

    # tools
    acpi
    atac
    bat
    bottom
    chafa
    claude-code
    csvlens
    curl
    devenv
    fd
    fzf
    gemini-cli
    glib
    glow
    inotify-tools
    jira-cli-go
    jq
    killall
    libinput
    libnotify
    mermaid-cli
    ollama-rocm
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
    uv
    zip

    # original config dependencies
    xdg-utils # Open files
  ];
}
