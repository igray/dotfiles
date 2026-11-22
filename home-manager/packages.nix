{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    acpi
    atac
    bat
    bottom
    chafa
    csvlens
    curl
    devenv
    fd
    git-filter-repo
    gitleaks
    glib
    herdr-core
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
    sshfs
    usbutils
    wget
    unzip
    uv
    zip

    # original config dependencies
    xdg-utils # Open files
  ];
}
