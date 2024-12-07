{ pkgs, ... }:
{
  extraPlugins = with pkgs.vimPlugins; [
    nvim-solarized-lua
  ];
  colorscheme = "solarized";
  globals = {
    solarized_visibility = "low";
  };
}
