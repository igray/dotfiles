{
  description = "Home Manager and NixOS configuration of Framework laptop";

  inputs = {
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11"; # Stable Nix Packages (Default)
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable"; # Unstable Nix Packages (Default)
    # nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable"; # Unstable Nix Packages
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lf-icons = {
      url = "https://raw.githubusercontent.com/gokcehan/lf/master/etc/icons.example";
      flake = false;
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      # If using a stable channel you can use `url = "github:nix-community/nixvim/nixos-<version>"`
      # inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nixvim-config = {
      url = "github:igray/nixvim-config?ref=lazyvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    claude-code.url = "github:sadjow/claude-code-nix";
    claude-desktop.url = "github:aaddrick/claude-desktop-debian?ref=v3.2.1%2Bclaude1.21459.0";
  };

  outputs =
    {
      home-manager,
      nixpkgs,
      # nixpkgs-unstable,
      nixos-hardware,
      ...
    }@inputs:
    let
      vars = {
        username = "igray";
        terminal = "ghostty";
      };
      system = "x86_64-linux";
      # unstable = import nixpkgs-unstable {
      #   inherit system;
      #   config = {
      #     allowUnfree = true;
      #     permittedInsecurePackages = [
      #     ];
      #   };
      # };
    in
    {
      nixosConfigurations."nixos" = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs vars system; };
        modules = [
          {
            nix.settings = {
              substituters = [
                "https://nix-community.cachix.org"
                "https://cache.nixos.org"
              ];
              trusted-public-keys = [
                "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
              ];
            };
          }
          nixos-hardware.nixosModules.framework-amd-ai-300-series
          ./hosts/laptop
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
            # unstable
            vars
            ;
        };
        modules = [
          {
            nixpkgs.overlays = import ./overlays { inherit inputs; };
          }
          inputs.nixvim.homeModules.nixvim
          inputs.sops-nix.homeManagerModules.sops
          ./home-manager/home.nix
        ];
      };
    };
}
