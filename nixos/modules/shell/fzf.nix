{ vars, ... }:

{
  home-manager.users.${vars.user} = {
    programs = {
      fzf = {
        enable = true;
        enableFishIntegration = true;
      };
    };
  };
}
