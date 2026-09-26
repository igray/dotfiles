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
        split_horizontal = [ "prefix+minus" "prefix+\"" ];
        split_vertical = "prefix+%";
        copy_mode = [ "prefix+[" "prefix+v" ];
        detach = [ "prefix+q" "prefix+d" ];
        rename_tab = [ "prefix+shift+t" "prefix+comma" ];
        close_tab = [ "prefix+shift+x" "prefix+ampersand" ];
        last_pane = "prefix+semicolon";
      };
    };
  };
}
