{ pkgs, ... }:
{
  services = {
    swayidle = {
      enable = true;
      events = [
        { event = "before-sleep"; command = "${pkgs.swaylock}/bin/swaylock -f"; }
        { event = "lock"; command = "${pkgs.swaylock}/bin/swaylock -f"; }
        { event = "lock"; command = "lock"; }
      ];
      timeouts = [
        { timeout = 600; command = "${pkgs.swaylock}/bin/swaylock -f"; }
        { timeout = 3600; command = "${pkgs.systemd}/bin/systemctl suspend"; }
      ];
    };
  };
}
