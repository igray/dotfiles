#
#  Neovim
#

{ pkgs, vars, ... }:

{
  programs = {
    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
    };
  };
  home-manager.users.${vars.user} = {
    programs = {
      neovim = {
        enable = true;
        viAlias = true;
        vimAlias = true;
        extraPackages = with pkgs; [
          elmPackages.elm-language-server
          elmPackages.lamdera
          fd                # Telescope
          lua-language-server
          nil
          nixpkgs-fmt
          nodePackages.prettier
          nodePackages.typescript-language-server
          nodePackages.vscode-langservers-extracted
          nodePackages.yaml-language-server
          ripgrep           # Telescope
          shfmt
          stylua
          zig               # Treesitter
        ];
        withNodeJs = true;
      };
    };
  };
}
