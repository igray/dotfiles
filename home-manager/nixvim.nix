{
  inputs,
  ...
}:
{
  programs.nixvim = {
    enable = true;
    nixpkgs.useGlobalPackages = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    defaultEditor = true;
    withNodeJs = false;
    withPerl = false;
    withPython3 = false;
    withRuby = false;

    imports = [
      inputs.nixvim-config.nixvimModule
    ];
  };
}
