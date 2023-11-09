{ vars, ... }:

{
  home-manager.users.${vars.user} = {
    programs = {
      starship = {
        enable = true;
        enableFishIntegration = true;
        settings = {
          add_newline = false;
        };
      };
    };
  };
}
