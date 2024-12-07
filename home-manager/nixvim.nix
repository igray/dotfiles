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
      inputs.Neve.nixvimModule
      ./nixvim
    ];
    colorschemes.enable = false;
    filetrees.enable = true;
    wakatime.enable = false;
  };
}
