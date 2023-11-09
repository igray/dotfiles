{ vars, ... }:

{
  home-manager.users.${vars.user} = {
    programs = {
      zoxide = {
        enable = true;
        enableFishIntegration = true;
      };
    };
  };
}
