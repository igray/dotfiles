{ config, ... }:
{
  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

    defaultSopsFile = ../secrets/secrets.yaml;

    secrets = {
      "rclone/careerplug-client-id" = { };
      "rclone/careerplug-client-secret" = { };
      "rclone/careerplug-gdrive-token" = { };
    };
  };
}
