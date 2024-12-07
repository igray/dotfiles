{ pkgs, vars, ... }:

with vars;
{
  systemd = {
    user = {
      services = {
        guardian = {
          wantedBy = [ "default.target" ];
          path = [ pkgs.nix ];
          script = "/home/${username}/.config/wallchange/guardian_pod.rb";
          description = "update wallpapers";
        };
      };
      timers = {
        guardian = {
          enable = true;
          wantedBy = [ "timers.target" ];
          description = "daily wallpaper update";
          timerConfig = {
            OnCalendar = "*-*-* 00/2:35";
            Persistent = true;
          };
        };
      };
    };
  };
}
