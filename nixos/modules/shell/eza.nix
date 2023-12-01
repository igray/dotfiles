{ vars, ... }:

{
  home-manager.users.${vars.user} = {
    programs = {
      eza = {
        enable = true;
        enableAliases = true;
        git = true;
        icons = true;
      };
    };
  };
}
