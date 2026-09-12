{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    # gui
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
    kdePackages.kdenlive
    libreoffice-stable
    obs-studio
    resources
    simple-scan
    shattered-pixel-dungeon
    slack
    spotify
    sshfs
    vlc
    warp-terminal
    wf-recorder
    wl-clipboard
    zoom-us

    # tools
    acpi
    atac
    bat
    bottom
    chafa
    claude-desktop-fhs
    csvlens
    curl
    devenv
    fd
    git-filter-repo
    gitleaks
    glib
    inotify-tools
    jira-cli-go
    jq
    killall
    libinput
    libnotify
    marp-cli
    mermaid-cli
    pandoc
    pciutils
    powertop
    qmk
    repgrep
    ripgrep
    s3fs
    slides
    socat
    usbutils
    wget
    unzip
    uv
    zip

    # original config dependencies
    xdg-utils # Open files
  ];
}
