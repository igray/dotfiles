{ config, lib, ... }:
let
  # Flat data dirs match the Arch layout, so the old /var/lib/<app> restores in place.
  arr = name: {
    services.${name} = {
      enable = true;
      group = "media";
      dataDir = "/var/lib/${name}";
    };
    systemd.services.${name}.serviceConfig.UMask = lib.mkForce "0002";
  };
in
lib.mkMerge [
  (arr "sonarr")
  (arr "radarr")
  (arr "readarr")
  {
    services.prowlarr.enable = true;

    services.calibre-web = {
      enable = true;
      listen = {
        ip = "0.0.0.0";
        port = 8083;
      };
      options.calibreLibrary = "/media/media/books/Calibre/Books";
    };

    # Second library; its port (8084) and library path live in its own app.db.
    systemd.services.calibre-web-vegan = {
      description = "Calibre-Web (Vegan)";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      unitConfig.RequiresMountsFor = [ "/media/media" ];
      serviceConfig = {
        User = config.services.calibre-web.user;
        Group = config.services.calibre-web.group;
        StateDirectory = "calibre-web-vegan";
        ExecStart = "${lib.getExe config.services.calibre-web.package} -p /var/lib/calibre-web-vegan/app.db -g /var/lib/calibre-web-vegan/gdrive.db -i 0.0.0.0";
        Restart = "on-failure";
      };
    };
  }
]
