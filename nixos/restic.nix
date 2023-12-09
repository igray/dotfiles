{ pkgs, vars, ...}:

let
  localServer = "192.168.86.10";
  localServerUser = "igray";
in
{
  environment.systemPackages = with pkgs; [
    restic
  ];
  services = {
    restic = {
      backups = {
        nightly = {
          passwordFile = "/etc/nixos/restic-password";
          environmentFile = "/etc/nixos/restic.env";
          repository = "s3:s3.amazonaws.com/resticlaptop";
          initialize = true;
          paths = [
            "/home/${vars.username}"
          ];
          exclude = [
            "node_modules"
            ".cache"
            ".config/Slack/**/Cache*"
          ];
          timerConfig = {
            OnCalendar = "12:00";
            RandomizedDelaySec = "1h";
            Persistent = true;
          };
          pruneOpts = [
            "--keep-daily 7"
            "--keep-weekly 5"
            "--keep-monthly 3"
          ];
          checkOpts = [
            "--with-cache"
          ];
        };
        work = {
          passwordFile = "/home/${vars.username}/.restic-password";
          repository = "sftp:${localServerUser}@${localServer}:/media/backup/restic";
          extraOptions = [
            "sftp.command='ssh ${localServerUser}@${localServer} -i /home/${vars.username}/.ssh/restic -s sftp'"
          ];
          initialize = true;
          user = vars.username;
          paths = [
            "/home/${localServerUser}/Work"
          ];
          exclude = [
            "node_modules"
          ];
          timerConfig = {
            OnCalendar = "Hourly";
            RandomizedDelaySec = "10m";
            Persistent = true;
          };
          pruneOpts = [
            "--keep-hourly 12"
            "--keep-daily 7"
            "--keep-weekly 5"
            "--keep-monthly 3"
          ];
          checkOpts = [
            "--with-cache"
          ];
        };
      };
    };
  };
}
