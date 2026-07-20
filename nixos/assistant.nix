{ pkgs, vars, ... }:

with vars;
{
  # Lingering so the user services run headless, without an active login.
  users.users.${username}.linger = true;

  systemd = {
    user = {
      services = {
        assistant = {
          wantedBy = [ "default.target" ];
          after = [
            "network-online.target"
            "devenv-cpats.service"
          ];
          wants = [
            "network-online.target"
            "devenv-cpats.service"
          ];
          path = with pkgs; [
            bash
            claude-code
            curl
            devenv
            direnv
            gawk
            gettext
            gh
            git
            jq
            nodejs
            python3
            uv
            worktrunk
          ];
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "/home/${username}/Work/assistant/dispatcher.sh";
            WorkingDirectory = "/home/${username}/Work/assistant";
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
            OnUnitActiveSec = "30min";
            Persistent = true;
          };
        };
      };
    };
  };
}
