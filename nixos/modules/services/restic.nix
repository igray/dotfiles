{ config, lib, pkgs, vars, ...}:

{
  environment.systemPackages = with pkgs; [
    restic
  ];
  services = {
    restic = {                  #7878
      backups = {
        nightly = {
          passwordFile = "/etc/nixos/restic-password";
          environmentFile = "/etc/nixos/restic.env";
          repository = "s3:s3.amazonaws.com/resticlaptop";
          initialize = true;
          paths = [
            "/home/igray"
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
          passwordFile = "/home/${vars.user}/.restic-password";
          repository = "sftp:igray@192.168.86.10:/media/backup/restic";
          extraOptions = [
            "sftp.command='ssh igray@192.168.86.10 -i /home/${vars.user}/.ssh/restic -s sftp'"
          ];
          initialize = true;
          user = vars.user;
          paths = [
            "/home/igray/Work"
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
