{ lib, ... }:
{
  plugins.lualine = {
    settings = {
      sections = {
        lualine_z = lib.mkForce [];
      };
    };
  };

  extraConfigLua = ''
    local custom_solarized = require'lualine.themes.solarized'

    custom_solarized.normal.b.bg = custom_solarized.normal.c.bg
    custom_solarized.normal.b.fg = custom_solarized.normal.c.fg

    require('lualine').setup {
      options = { theme  = custom_solarized },
    }
  '';
}
