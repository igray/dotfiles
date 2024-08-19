{
  description = "Home Manager and NixOS configuration of Framework laptop";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";                     # Stable Nix Packages (Default)
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";         # Unstable Nix Packages
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ags.url = "github:Aylur/ags";
    lf-icons = {
      url = "https://raw.githubusercontent.com/gokcehan/lf/master/etc/icons.example";
      flake = false;
    };
    more-waita = {
      url = "https://github.com/somepaulo/MoreWaita/archive/refs/heads/main.zip";
      flake = false;
    };
    firefox-gnome-theme = {
      url = "https://github.com/rafaelmardojai/firefox-gnome-theme/archive/master.tar.gz";
      flake = false;
    };
    nixos-cosmic = {
      url = "github:lilyinstarlight/nixos-cosmic";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { home-manager, nixpkgs, nixpkgs-unstable, nixos-hardware, nixos-cosmic, ... }@inputs:
  let
    vars = {
      username = "igray";
      terminal = "alacritty";
    };
    system = "x86_64-linux";
    unstable = import nixpkgs-unstable {
      inherit system;
      config = {
        allowUnfree = true;
        permittedInsecurePackages = [
          "electron-27.3.11" # logseq
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
             substituters = [ "https://cosmic.cachix.org/" ];
             trusted-public-keys = [ "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE=" ];
           };
         }
         nixos-cosmic.nixosModules.default
         nixos-hardware.nixosModules.framework-13-7040-amd
        ./nixos/configuration.nix
      ];
    };

    homeConfigurations."${vars.username}" = home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      extraSpecialArgs = { inherit inputs unstable vars; };
      modules = [ ./home-manager/home.nix ];
    };
  };
}
