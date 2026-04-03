{ pkgs, vars, ... }:

with vars;
{
  systemd = {
    user = {
      services = {
        assistant = {
          wantedBy = [ "default.target" ];
          after = [ "network-online.target" ];
          wants = [ "network-online.target" ];
          path = with pkgs; [
            bash
            gh
            jq
            python3
            uv
          ];
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "/home/${username}/Work/assistant/dispatcher.sh";
            WorkingDirectory = "/home/${username}/Work/assistant";
            TimeoutStartSec = 600;
          };
          description = "Personal Assistant Dispatcher";
        };
      };
      timers = {
        assistant = {
          enable = true;
          wantedBy = [ "timers.target" ];
          description = "Personal Assistant Timer";
          timerConfig = {
            OnUnitActiveSec = "15min";
            Persistent = true;
          };
        };
      };
    };
  };
}
