{ config, pkgs, ... }:
let
  proxyTo = port: {
    forceSSL = true;
    enableACME = true;
    extraConfig = ''
      client_max_body_size 20M;
      add_header X-Frame-Options "SAMEORIGIN";
      add_header X-Content-Type-Options "nosniff";
    '';
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString port}";
      proxyWebsockets = true;
      extraConfig = "proxy_buffering off;";
    };
  };
in
{
  security.acme = {
    acceptTerms = true;
    defaults.email = "igray78756@gmail.com";
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;

    virtualHosts = {
      "aiostreams.igster.org" = proxyTo 8090;
      "medialists.igster.org" = proxyTo 8000;
      "photos.igster.org" = proxyTo 2283;
      "video.igster.org" = proxyTo 8096;
      ${config.services.nextcloud.hostName} = {
        forceSSL = true;
        enableACME = true;
      };
    };
  };

  # Nextcloud refuses to skip a major version or to downgrade, so this pin
  # moves one major at a time and never behind the restored database.
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud35;
    hostName = "cloud.igster.org";
    https = true;
    maxUploadSize = "1000M";
    database.createLocally = true;
    config.dbtype = "mysql";
    settings.files_external_allow_create_new_local = true;
  };
}
