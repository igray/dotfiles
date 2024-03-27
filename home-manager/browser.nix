{ inputs, pkgs, ... }:
{
  home = {
    sessionVariables.BROWSER = "firefox";

    packages = with pkgs; [
      brave
    ];

    file."firefox-gnome-theme" = {
      target = ".mozilla/firefox/default/chrome/firefox-gnome-theme";
      source = inputs.firefox-gnome-theme;
    };

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
        settings = {
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          "svg.context-properties.content.enabled" = true;
          "gnomeTheme.hideSingleTab" = true;
          "gnomeTheme.bookmarksToolbarUnderTabs" = true;
          "gnomeTheme.normalWidthTabs" = false;
          "gnomeTheme.tabsAsHeaderbar" = false;
        };
        userChrome = ''
          @import "firefox-gnome-theme/userChrome.css";
        '';
        userContent = ''
          @import "firefox-gnome-theme/userContent.css";
        '';
      };
    };
  };
}
