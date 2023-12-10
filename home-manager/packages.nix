{ pkgs, ... }:
{
  home.packages = with pkgs; with nodePackages_latest; with gnome; [
    # gui
    (mpv.override { scripts = [mpvScripts.mpris]; })
    authenticator
    d-spy
    dconf-editor
    discord
    gimp
    icon-library
    libreoffice-fresh
    simple-scan
    slack
    spotify
    logseq
    vlc
    zoom-us

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
    socat
    unzip
    usbutils
    wget
    unzip
    zip

    # hyprland
    brightnessctl
    hyprpicker
    imagemagick
    pavucontrol
    slurp
    swappy
    swww
    wayshot
    wf-recorder
    wl-clipboard
    wl-gammactl
  ];
}
