{ config, ... }:
let
  firefoxDesktop = "firefox.desktop";

  # Chromium honours only the last `--enable-features`, and these land after
  # the nixpkgs wrapper's own set -- adding one here silently drops it.
  chromiumArgs = [
    "--ozone-platform-hint=auto"
    "--password-store=gnome"
  ];
in
{
  home.sessionVariables.BROWSER = "firefox";

  programs = {
    firefox = {
      enable = true;
      profiles.default = {
        name = "Default";
      };
      configPath = "${config.xdg.configHome}/mozilla/firefox";
    };

    brave = {
      enable = true;
      commandLineArgs = chromiumArgs;
    };

    google-chrome = {
      enable = true;
      commandLineArgs = chromiumArgs;
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
