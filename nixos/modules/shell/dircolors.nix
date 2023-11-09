{ vars, ... }:

{
  home-manager.users.${vars.user} = {
    programs = {
      dircolors = {
        enable = true;
        enableFishIntegration = true;
      };
    };
  };
}
