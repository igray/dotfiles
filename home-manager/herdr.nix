{ ... }:
{
  programs.herdr = {
    enable = true;
    settings = {
      onboarding = false;
      theme = {
        name = "solarized";
        auto_switch = false;
      };
      ui = {
        sound.enabled = false;
        toast.delivery = "system";
      };
      keys = {
        prefix = "ctrl+space";
        new_worktree = "";
      };
    };
  };
}
