{
  description = "Flake Cereal - Brand new recipe!";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-ld.url = "github:Mic92/nix-ld";
    nix-ld.inputs.nixpkgs.follows = "nixpkgs";
    nix-alien.url = "github:thiagokokada/nix-alien";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    fjordlauncher.url = "github:unmojang/fjordlauncher";
  };

  outputs = inputs@{ self, nixpkgs, home-manager, nix-ld, nixos-wsl, nix-alien
    , fjordlauncher, }: {
      nixosConfigurations = {
        juniper = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs self fjordlauncher; };
          modules = [
            nix-ld.nixosModules.nix-ld
            ./common/nix-ld.nix
            ./common/nix-alien.nix
            ./common/fjordlauncher.nix
            ./juniper/system.nix
            home-manager.nixosModules.home-manager
            ./juniper/home-manager.nix

          ];
        };
        elder = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [ ./elder/system.nix ];
        };
        yggdrasil = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs self fjordlauncher; };
          modules = [
            nix-ld.nixosModules.nix-ld
            ./common/nix-ld.nix
            ./common/nix-alien.nix
            ./common/fjordlauncher.nix
            ./yggdrasil/system.nix
            home-manager.nixosModules.home-manager
            ./yggdrasil/home-manager.nix
          ];
        };
        wsl-nixos = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs self; };
          modules = [
            nixos-wsl.nixosModules.default
            nix-ld.nixosModules.nix-ld
            ./common/nix-ld.nix
            ./common/nix-alien.nix
            ./wsl-nixos/system.nix
          ];
        };

      };
    };
}
