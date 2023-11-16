#
#  These are the different profiles that can be used when building NixOS.
#
#  flake.nix 
#   └─ ./hosts  
#       ├─ default.nix *
#       ├─ configuration.nix
#       └─ ./<host>.nix
#           └─ default.nix 
#

{ lib, inputs, nixpkgs, nixpkgs-unstable, home-manager, nur, vars, ... }:

let
  system = "x86_64-linux";                                  # System Architecture

  pkgs = import nixpkgs {
    inherit system;
    config.allowUnfree = true;                              # Allow Proprietary Software
  };

  unstable = import nixpkgs-unstable {
    inherit system;
    config.allowUnfree = true;
  };

  lib = nixpkgs.lib;
in
{
  framework = lib.nixosSystem {                                  # Work Profile
    inherit system;
    specialArgs = {
      inherit inputs system unstable vars;
      host = {
        hostName = "framework";
        mainMonitor = "eDP-1";
        secondMonitor = "DP-3";
        thirdMonitor = "DP-7";
      };
    };
    modules = [
      ./framework
      ./configuration.nix

      home-manager.nixosModules.home-manager {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
      }
    ];
  };
}
