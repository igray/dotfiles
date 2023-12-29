{ ... }:
{
  programs = {
    alacritty = {
      enable = true;
      settings = {
        window.decorations = "None";
        font = {
          size = 11.0;
          normal = {
            family = "JetBrainsMono Nerd Font";
            style = "ExtraLight";
          };
          bold = {
            family = "JetBrainsMono Nerd Font";
            style = "Medium";
          };
          italic = {
            family = "JetBrainsMono Nerd Font";
            style = "Italic";
          };
          bold_italic = {
            family = "JetBrainsMono Nerd Font";
            style = "Medium Italic";
          };
          built_in_box_drawing = false;
        };
        colors = {
          primary = {
            background = "#002b36";
            foreground = "#839496";
          };
          normal = {
            black   = "#073642";
            red     = "#dc322f";
            green   = "#859900";
            yellow  = "#b58900";
            blue    = "#268bd2";
            magenta = "#d33682";
            cyan    = "#2aa198";
            white   = "#eee8d5";
          };
          bright = {
            black   = "#002b36";
            red     = "#cb4b16";
            green   = "#586e75";
            yellow  = "#657b83";
            blue    = "#839496";
            magenta = "#6c71c4";
            cyan    = "#93a1a1";
            white   = "#fdf6e3";
          };
        };
      };
    };
  };
}
