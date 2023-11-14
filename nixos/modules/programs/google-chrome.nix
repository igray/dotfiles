{ pkgs, unstable, vars, ...}:

{
  home-manager.users.${vars.user} = {
    programs = {
      google-chrome = {
        enable = true;
        commandLineArgs = [
          "--enable-features=VaapiVideoDecoder,VaapiVideoEncoder"
          "--password-store=gnome"
        ];
      };
    };
  };
}
