{
  description = "Home Manager and NixOS configuration of Framework laptop";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05"; # Stable Nix Packages (Default)
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable"; # Unstable Nix Packages
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lf-icons = {
      url = "https://raw.githubusercontent.com/gokcehan/lf/master/etc/icons.example";
      flake = false;
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      # If using a stable channel you can use `url = "github:nix-community/nixvim/nixos-<version>"`
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nixvim-config = {
      url = "github:igray/nixvim-config";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      home-manager,
      nixpkgs,
      nixpkgs-unstable,
      nixos-hardware,
      ...
    }@inputs:
    let
      vars = {
        username = "igray";
        terminal = "ghostty";
      };
      system = "x86_64-linux";
      unstable = import nixpkgs-unstable {
        inherit system;
        config = {
          allowUnfree = true;
          permittedInsecurePackages = [
          ];
        };
      };
    in
    {
      nixosConfigurations."nixos" = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs vars system; };
        modules = [
          {
            nix.settings = {
              substituters = [
                "https://cosmic.cachix.org/"
                "https://nix-community.cachix.org"
                "https://cache.nixos.org"
              ];
              trusted-public-keys = [
                "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE="
                "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
              ];
            };
          }
          nixos-hardware.nixosModules.framework-13-7040-amd
          ./nixos/configuration.nix
        ];
      };

      homeConfigurations."${vars.username}" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          config.joypixels.acceptLicense = true;
        };
        extraSpecialArgs = {
          inherit
            inputs
            unstable
            vars
            ;
        };
        modules = [
          inputs.nixvim.homeModules.nixvim
          ./home-manager/home.nix
        ];
      };
    };
}
