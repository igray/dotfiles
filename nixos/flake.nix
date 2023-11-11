#
#  flake.nix *             
#   ├─ ./hosts
#   │   └─ default.nix
#

{
  description = "NixOS Flake Configuration";

  inputs =                                                                  # References Used by Flake
    {
      nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";                     # Stable Nix Packages (Default)
      nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";         # Unstable Nix Packages

      home-manager = {                                                      # User Environment Manager
        url = "github:nix-community/home-manager/release-23.05";
        inputs.nixpkgs.follows = "nixpkgs";
      };

      nur = {                                                               # NUR Community Packages
        url = "github:nix-community/NUR";                                   # Requires "nur.nixosModules.nur" to be added to the host modules
      };

      nixgl = {                                                             # Fixes OpenGL With Other Distros.
        url = "github:guibou/nixGL";
        inputs.nixpkgs.follows = "nixpkgs";
      };

      # hyprland = {                                                          # Official Hyprland Flake
      #   url = "github:hyprwm/Hyprland";                                     # Requires "hyprland.nixosModules.default" to be added the host modules
      #   inputs.nixpkgs.follows = "nixpkgs-unstable";
      # };
    };

  outputs = inputs @ { self, nixpkgs, nixpkgs-unstable, home-manager, nur, nixgl, ... }:   # Function telling flake which inputs to use
    let
      vars = {                                                              # Variables Used In Flake
        user = "igray";
        location = "$HOME/.setup";
        terminal = "wezterm";
        editor = "nvim";
      };
    in
    {
      nixosConfigurations = (                                               # NixOS Configurations
        import ./hosts {
          inherit (nixpkgs) lib;
          inherit inputs nixpkgs nixpkgs-unstable home-manager nur vars;   # Inherit inputs
        }
      );
    };
}