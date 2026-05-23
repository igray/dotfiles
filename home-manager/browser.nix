{ config, pkgs, ... }:
let
  firefoxDesktop = "firefox.desktop";
in
{
  home = {
    sessionVariables.BROWSER = "firefox";

    packages = with pkgs; [
      brave
    ];

    file."brave-config" = {
      target = ".config/brave-flags.conf";
      text = ''
        --enable-features=VaapiVideoDecoder,VaapiVideoEncoder,VaapiVideoDecodeLinuxGL
        --ozone-platform-hint=auto
        --password-store=gnome
      '';
    };
  };

  programs = {
    firefox = {
      enable = true;
      profiles.default = {
        name = "Default";
      };
      configPath = "${config.xdg.configHome}/mozilla/firefox";
    };
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = firefoxDesktop;
      "text/xml" = firefoxDesktop;
      "application/xhtml+xml" = firefoxDesktop;
      "application/xml" = firefoxDesktop;
      "x-scheme-handler/http" = firefoxDesktop;
      "x-scheme-handler/https" = firefoxDesktop;
      "x-scheme-handler/ftp" = firefoxDesktop;
      "x-scheme-handler/about" = firefoxDesktop;
      "x-scheme-handler/unknown" = firefoxDesktop;
      "x-scheme-handler/chrome" = firefoxDesktop;
    };
  };
}
