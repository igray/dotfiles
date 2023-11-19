#
#  Terminal Emulator
#

{ pkgs, vars, ... }:

{
  home-manager.users.${vars.user} = {
    programs = {
      kitty = {
        enable = true;
        theme = "Solarized Dark";
        font = {
          name = "JetBrainsMono NF Light";
          size = 11;
        };
        shellIntegration = {
          enableFishIntegration = true;
        };
        settings = {
          confirm_os_window_close=0;
        };
      };
    };
  };
}
