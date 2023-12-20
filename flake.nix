{
  description = "Home Manager and NixOS configuration of Framework laptop";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";                     # Stable Nix Packages (Default)
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";         # Unstable Nix Packages
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
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
  };

  outputs = { home-manager, nixpkgs, nixpkgs-unstable, ... }@inputs:
  let
    vars = {
      username = "igray";
      terminal = "kitty";
    };
    system = "x86_64-linux";
    unstable = import nixpkgs-unstable {
      inherit system;
      config = {
        allowUnfree = true;
        permittedInsecurePackages = [
          "electron-25.9.0" # logseq
        ];
      };
    };
  in
  {
    nixosConfigurations."nixos" = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs vars system; };
      modules = [ ./nixos/configuration.nix ];
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
