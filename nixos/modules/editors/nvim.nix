#
#  Neovim
#

{ pkgs, ... }:

{
  environment = {
    systemPackages = with pkgs; [           # System-Wide Packages
      nodejs_20         # Mason
      ripgrep           # Telescope
      fd                # Telescope
      gcc               # Treesitter
      gnumake           # Mason (build dependencies)
    ];
  };
  programs = {
    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
    };
  };
}
