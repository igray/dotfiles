{ pkgs, vars, ... }:

{
  home-manager.users.${vars.user} = {
    services = {
      gnome-keyring = {
        enable = true;
        components = [ "secrets" "ssh" ];
      };
    };
  };
}
