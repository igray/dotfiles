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
        # wallchange = {
        #   wantedBy = [ "default.target" ];
        #   path = [ pkgs.nix pkgs.bash pkgs.hyprland ];
        #   script = "/home/${username}/.config/wallchange/wallchange.sh";
        #   description = "change the wallpaper";
        # };
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
        # wallchange = {
        #   enable = true;
        #   wantedBy = [ "timers.target" ];
        #   description = "hourly wallpaper change";
        #   timerConfig = {
        #     OnCalendar = "*-*-* *:50:00";
        #     Persistent = true;
        #   };
        # };
      };
    };
  };
}
