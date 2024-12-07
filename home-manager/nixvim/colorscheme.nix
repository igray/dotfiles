{ pkgs, ... }:
{
  extraPlugins = [(pkgs.vimUtils.buildVimPlugin {
    name = "solarized";
    isColorscheme = true;
    originalName = "nvim-solarized-lua";
    src = pkgs.fetchFromGitHub {
      owner = "ishan9299";
      repo = "nvim-solarized-lua";
      rev = "d69a263c97cbc765ca442d682b3283aefd61d4ac";
      hash = "sha256-0NABkr2d86Uq3OU4lbn2dyjRbwE3+5euqh1CA+MwDtQ=";
    };
  })];
  colorscheme = "solarized";
  globals = {
    solarized_visibility = "low";
  };
}
