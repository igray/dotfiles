{ pkgs, ... }:
let
  xterm = pkgs.writeShellScriptBin "xterm" ''
    ${pkgs.wezterm}/bin/wezterm "$@"
  '';
in
{
  home.packages = [
    xterm
  ];

  programs = {
    wezterm = {
      enable = true;
      extraConfig = ''
        return {
          enable_wayland = false,
          color_scheme = "Builtin Solarized Dark",
          --font = wezterm.font("M+2 Nerd Font Propo", {weight="ExtraLight"}),
          font = wezterm.font("JetBrainsMono Nerd Font", {weight="ExtraLight"}),
          font_size = 11.0,
          -- title_font = wezterm.font("JetBrainsMono Nerd Font", {weight="ExtraLight"}),
          enable_kitty_graphics = true,
          font_rules= {
            -- Select a fancy italic font for italic text
            {
              italic = true,
              font = wezterm.font("JetBrainsMono Nerd Font", {weight="ExtraLight", italic=true}),
            },

            -- Similarly, a fancy bold+italic font
            {
              italic = true,
              intensity = "Bold",
              font = wezterm.font("JetBrainsMono Nerd Font", {weight="Medium", italic=true}),
            },

            -- Make regular bold text a different color to make it stand out even more
            {
              intensity = "Bold",
              font = wezterm.font("JetBrainsMono Nerd Font", {weight="Medium"}),
            },

            -- For half-intensity text, use a lighter weight font
            {
              italic = true,
              intensity = "Half",
              font = wezterm.font("JetBrainsMono Nerd Font", {weight="Thin", italic=true}),
            },
            {
              intensity = "Half",
              font = wezterm.font("JetBrainsMono Nerd Font", {weight="Thin"}),
            },
          },
          hide_mouse_cursor_when_typing = false,
          hide_tab_bar_if_only_one_tab = true,
          quick_select_patterns = {
            "CP-[^\\s]+",
          },
          warn_about_missing_glyphs = false,
          window_frame = {
            inactive_titlebar_bg = "#353535",
            active_titlebar_bg = "#0a2730",
            inactive_titlebar_fg = "#eee8d5",
            active_titlebar_fg = "#eee8d5",
            inactive_titlebar_border_bottom = "#353535",
            active_titlebar_border_bottom = "#0a2730",
            button_fg = "#eee8d5",
            button_bg = "#0a2730",
            button_hover_fg = "#eee8d5",
            button_hover_bg = "#073542",
          },
          keys = {
            {key="1", mods="ALT", action=wezterm.action{ActivateTab=0}},
            {key="2", mods="ALT", action=wezterm.action{ActivateTab=1}},
            {key="3", mods="ALT", action=wezterm.action{ActivateTab=2}},
            {key="4", mods="ALT", action=wezterm.action{ActivateTab=3}},
            {key="5", mods="ALT", action=wezterm.action{ActivateTab=4}},
            {key="6", mods="ALT", action=wezterm.action{ActivateTab=5}},
            {key="7", mods="ALT", action=wezterm.action{ActivateTab=6}},
            {key="8", mods="ALT", action=wezterm.action{ActivateTab=7}},
            {key="9", mods="ALT", action=wezterm.action{ActivateTab=-1}},
            {key="0", mods="ALT", action="ShowTabNavigator"},
            {key="[", mods="ALT", action=wezterm.action{ActivateTabRelative=-1}},
            {key="]", mods="ALT", action=wezterm.action{ActivateTabRelative=1}},
            {key="o", mods="CTRL|SHIFT", action="ActivateLastTab"},
            {key="'", mods="CTRL|ALT", action=wezterm.action{SplitVertical={domain="CurrentPaneDomain"}}},
            {key="5", mods="CTRL|ALT", action=wezterm.action{SplitHorizontal={domain="CurrentPaneDomain"}}},
            {key="k", mods="CTRL|SHIFT", action=wezterm.action{ActivatePaneDirection="Up"}},
            {key="j", mods="CTRL|SHIFT", action=wezterm.action{ActivatePaneDirection="Down"}},
            {key="h", mods="CTRL|SHIFT", action=wezterm.action{ActivatePaneDirection="Left"}},
            {key="l", mods="CTRL|SHIFT", action=wezterm.action{ActivatePaneDirection="Right"}},
            {key="UpArrow", mods="CTRL|ALT", action=wezterm.action{AdjustPaneSize={"Up",1}}},
            {key="DownArrow", mods="CTRL|ALT", action=wezterm.action{AdjustPaneSize={"Down",1}}},
            {key="LeftArrow", mods="CTRL|ALT", action=wezterm.action{AdjustPaneSize={"Left",1}}},
            {key="RightArrow", mods="CTRL|ALT", action=wezterm.action{AdjustPaneSize={"Right",1}}},
            {key="z", mods="CTRL|SHIFT", action="TogglePaneZoomState"},
            {key = 'w', mods = 'CMD', action = wezterm.action.CloseCurrentPane { confirm = true }},
          }
        }
      '';
    };
  };
}
