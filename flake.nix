{
    description = "Flake Cereal - Brand new recipe!";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
        home-manager.url = "github:nix-community/home-manager";
        home-manager.inputs.nixpkgs.follows = "nixpkgs";
        inputs.nix-ld.url = "github:Mic92/nix-ld";
        inputs.nix-ld.inputs.nixpkgs.follows = "nixpkgs";
        nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    };

    outputs = inputs@{ self, nixpkgs, home-manager }: {
        nixosConfigurations = {
            juniper = nixpkgs.lib.nixosSystem {
                system = "x86_64-linux";
                specialArgs = { inherit inputs; };
                modules = [
                    nix-ld.nixosModules.nix-ld
                    ./juniper/system.nix 
                    home-manager.nixosModules.home-manager ./juniper/home-manager.nix
                ];
            };
            elder = nixpkgs.lib.nixosSystem {
                system = "x86_64-linux";
                specialArgs = { inherit inputs; };
                modules = [
                    ./elder/system.nix 
                ];
            };
            yggdrasil = nixpkgs.lib.nixosSystem {
                system = "x86_64-linux";
                specialArgs = { inherit inputs; };
                modules = [
                    nix-ld.nixosModules.nix-ld
                    ./common/nix-ld.nix
                    ./yggdrasil/system.nix
                    home-manager.nixosModules.home-manager ./yggdrasil/home-manager.nix
                ];
            };
            wsl = nixpkgs.lib.nixosSystem {
                system = "x86_64-linux";
                specialArgs = { inherit inputs; };
                modules = [
                    nixos-wsl.nixosModules.default
                    nix-ld.nixosModules.nix-ld
                    ./common/nix-ld.nix
                    ./wsl/system.nix
                ];
            };
        };
    };
}