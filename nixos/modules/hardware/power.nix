#
#  Power Management
#

{ config, lib, pkgs, vars, ... }:

{
  config = lib.mkIf ( config.laptop.enable ) {
    services = {
      tlp.enable = true;                          # Power Efficiency
      auto-cpufreq = {
        enable = false;
        settings = {
          charger = {
            governor = "performance";
            turbo = "auto";
          };
          battery = {
            governor = "powersave";
            turbo = "auto";
          };
        };
      };
    };

    home-manager.users.${vars.user} = {
      services = {
        cbatticon = {                             # Battery Level Notifications
          enable = true;
          criticalLevelPercent = 10;
          commandCriticalLevel = ''notify-send "battery critical!"'';
          lowLevelPercent = 30;
          iconType = "standard";
        };
      };
    };
  };
}
