{ config, ... }:
{
  programs.rclone = {
    enable = true;

    remotes.careerplug-drive = {
      config = {
        type = "drive";
        scope = "drive";
      };
      secrets = {
        client_id = config.sops.secrets."rclone/careerplug-client-id".path;
        client_secret = config.sops.secrets."rclone/careerplug-client-secret".path;
        token = config.sops.secrets."rclone/careerplug-gdrive-token".path;
      };
    };

    # Uncomment to enable automatic mounting
    # remotes.gdrive.mounts.gdrive = {
    #   enable = true;
    #   mountPoint = "${config.home.homeDirectory}/gdrive";
    #   autoMount = true;
    #   options = {
    #     vfs-cache-mode = "full";
    #     dir-cache-time = "72h";
    #   };
    # };
  };
}
