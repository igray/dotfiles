{ pkgs, vars, ... }:

{
  environment.systemPackages = with pkgs; [
    gcr
  ];
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;
  programs.seahorse.enable = true;
  home-manager.users.${vars.user} = {
    services = {
      gnome-keyring = {
        enable = true;
        components = [ "secrets" "ssh" ];
      };
    };
  };
}
