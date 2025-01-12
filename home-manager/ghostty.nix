{ pkgs, inputs, ... }:
{
  programs.ghostty = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      theme = "Builtin Solarized Dark";
      font-family = "JetBrainsMono Nerd Font";
      font-family-bold = "JetBrainsMono Nerd Font";
      font-family-italic = "JetBrainsMono Nerd Font";
      font-family-bold-italic = "JetBrainsMono Nerd Font";
      font-style = "ExtraLight";
      font-style-bold = "Medium";
      font-style-italic = "ExtraLight Italic";
      font-style-bold-italic = "Medium Italic";
      font-size = 11.4;
      window-decoration = false;
      keybind = [
        "alt+w=toggle_window_decorations"
      ];
    };
  };
}
