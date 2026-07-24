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
    claude-desktop.url = "github:aaddrick/claude-desktop-debian?ref=v3.2.1%2Bclaude1.24012.0";
  };

  outputs =
    {
      home-manager,
      nixpkgs,
      nixos-hardware,
      ...
    }@inputs:
    let
      vars = {
        username = "igray";
        terminal = "ghostty";
      };
      system = "x86_64-linux";

      cachixSettings = {
        nix.settings = {
          substituters = [
            "https://nix-community.cachix.org"
            "https://cache.nixos.org"
          ];
          trusted-public-keys = [
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          ];
        };
      };

      mkNixos =
        { hostModule, hwModules ? [ ] }:
        nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs vars system; };
          modules = [ cachixSettings ] ++ hwModules ++ [ hostModule ];
        };

      mkHome =
        homeModule:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
            config.joypixels.acceptLicense = true;
          };
          extraSpecialArgs = { inherit inputs vars; };
          modules = [
            { nixpkgs.overlays = import ./overlays { inherit inputs; }; }
            inputs.nixvim.homeModules.nixvim
            inputs.sops-nix.homeManagerModules.sops
            homeModule
          ];
        };
    in
    {
      nixosConfigurations = {
        laptop = mkNixos {
          hostModule = ./hosts/laptop;
          hwModules = [ nixos-hardware.nixosModules.framework-amd-ai-300-series ];
        };
        "work-server" = mkNixos {
          hostModule = ./hosts/work-server;
          hwModules = [ nixos-hardware.nixosModules.framework-13-7040-amd ];
        };
      };

      homeConfigurations = {
        "igray@laptop" = mkHome ./home-manager/laptop.nix;
        "igray@work-server" = mkHome ./home-manager/work-server.nix;
      };
    };
}
