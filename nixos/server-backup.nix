{ config, pkgs, ... }:
let
  dumpDir = "/var/backup/db";
  secrets = config.sops.secrets;
  placeholder = config.sops.placeholder;

  paths = [
    "/etc/ssh"
    "/home/igray"
    "/opt"
    "/var/lib"
    dumpDir
    "/media/media/photos"
  ];

  exclude = [
    "/var/lib/docker"
    "/var/lib/containerd"
    "/var/lib/mysql"
    "/var/lib/systemd/coredump"
    "/opt/immich-app/postgres"
    "/media/media/photos/thumbs"
    "/media/media/photos/encoded-video"
    "/home/igray/.cache"
  ];

  backup = repository: environmentFile: timer: {
    inherit
      repository
      environmentFile
      paths
      exclude
      ;
    passwordFile = secrets."restic/password".path;
    initialize = true;
    timerConfig = {
      OnCalendar = timer;
      RandomizedDelaySec = "30m";
      Persistent = true;
    };
    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 4"
      "--keep-monthly 6"
    ];
    checkOpts = [ "--with-cache" ];
    backupPrepareCommand = ''
      ${pkgs.curl}/bin/curl -fsS -m 10 --retry 5 "$HC_URL/start" || true
      ${pkgs.restic}/bin/restic unlock || true
    '';
    # systemd sets EXIT_STATUS for ExecStopPost; healthchecks.io treats a non-zero path suffix as a failure.
    backupCleanupCommand = ''
      ${pkgs.curl}/bin/curl -fsS -m 10 --retry 5 "$HC_URL/''${EXIT_STATUS:-1}"
    '';
  };
in
{
  sops = {
    defaultSopsFile = ../secrets/server.yaml;
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    secrets = {
      "restic/password" = { };
      "restic/aws-access-key-id" = { };
      "restic/aws-secret-access-key" = { };
      "restic/healthcheck-local" = { };
      "restic/healthcheck-s3" = { };
    };

    templates."restic-local.env".content = ''
      HC_URL=${placeholder."restic/healthcheck-local"}
    '';
    templates."restic-s3.env".content = ''
      HC_URL=${placeholder."restic/healthcheck-s3"}
      AWS_ACCESS_KEY_ID=${placeholder."restic/aws-access-key-id"}
      AWS_SECRET_ACCESS_KEY=${placeholder."restic/aws-secret-access-key"}
      AWS_DEFAULT_REGION=us-east-2
    '';
  };

  services.restic.backups = {
    local = backup "/media/backup/restic-server" config.sops.templates."restic-local.env".path "02:00";
    s3 =
      backup "s3:s3.us-east-2.amazonaws.com/server-backup-019021103620-us-east-2-an"
        config.sops.templates."restic-s3.env".path
        "04:00";
  };

  systemd.tmpfiles.rules = [ "d ${dumpDir} 0700 root root -" ];

  systemd.services = {
    backup-db-dump = {
      description = "Dump the Nextcloud and Immich databases for restic";
      after = [
        "mysql.service"
        "compose-immich.service"
      ];
      path = [
        config.services.mysql.package
        config.virtualisation.docker.package
        pkgs.gzip
      ];
      serviceConfig = {
        Type = "oneshot";
        UMask = "0077";
      };
      script = ''
        set -o pipefail
        mariadb-dump --single-transaction nextcloud | gzip > ${dumpDir}/nextcloud.sql.gz.tmp
        mv ${dumpDir}/nextcloud.sql.gz.tmp ${dumpDir}/nextcloud.sql.gz
        docker exec immich_postgres pg_dumpall --clean --if-exists --username=postgres \
          | gzip > ${dumpDir}/immich.sql.gz.tmp
        mv ${dumpDir}/immich.sql.gz.tmp ${dumpDir}/immich.sql.gz
      '';
    };

    restic-backups-local = {
      requires = [ "backup-db-dump.service" ];
      after = [ "backup-db-dump.service" ];
      unitConfig.RequiresMountsFor = [
        "/media/backup"
        "/media/media"
      ];
    };
    restic-backups-s3 = {
      requires = [ "backup-db-dump.service" ];
      after = [ "backup-db-dump.service" ];
      unitConfig.RequiresMountsFor = [ "/media/media" ];
    };
  };
}
