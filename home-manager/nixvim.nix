{ inputs, ... }:
{
  programs.nixvim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    defaultEditor = true;
    withNodeJs = true;

    imports = [
      inputs.nixvim-config.nixvimModule
    ];
  };
}
