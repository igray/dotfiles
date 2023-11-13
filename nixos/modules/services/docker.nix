{ config, lib, pkgs,...}:

with lib;
{
  options = {
    docker = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };

  config = mkIf (config.docker.enable)
  {
    virtualisation.docker.enable = true;
  };
}
