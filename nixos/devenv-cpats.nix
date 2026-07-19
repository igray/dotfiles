{ pkgs, vars, ... }:

with vars;
{
  # Single systemd-managed `devenv up` for the CPATS (atsnix) checkout, so a
  # stray second `devenv up` is a no-op instead of re-evaluating and bumping
  # the process-compose ports.
  systemd.user.services.devenv-cpats = {
    wantedBy = [ "default.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    path = with pkgs; [
      bash
      coreutils
      direnv
      devenv
      git
      nix
    ];
    serviceConfig = {
      # `direnv exec` loads the atsnix .envrc so `devenv up` gets the same
      # environment as an interactive shell.
      ExecStart = "${pkgs.direnv}/bin/direnv exec /home/${username}/Work/cp/atsnix ${pkgs.devenv}/bin/devenv up";
      WorkingDirectory = "/home/${username}/Work/cp/atsnix";
      Restart = "on-failure";
      RestartSec = 10;
    };
    description = "CPATS devenv services (single shared instance)";
  };
}
