{ inputs, pkgs, ... }:
{
  home = {
    sessionVariables.BROWSER = "brave";

    packages = with pkgs; [
      brave
    ];

    file."brave-config" = {
      target = ".config/brave-flags.conf";
      text = ''
        --enable-features=VaapiVideoDecoder,VaapiVideoEncoder,VaapiVideoDecodeLinuxGL
        --ozone-platform-hint=auto
        --password-store=gnome
      '';
    };
  };

  programs = {
    firefox = {
      enable = true;
      profiles.default = {
        name = "Default";
      };
    };
  };
}
