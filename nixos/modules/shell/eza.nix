{ vars, ... }:

{
  home-manager.users.${vars.user} = {
    programs = {
      exa = { # TODO: update to eza
        enable = true;
        enableAliases = true;
        git = true;
        icons = true;
      };
    };
  };
}
