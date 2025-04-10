{
    description = "Flake Cereal - Brand new recipe!";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
        home-manager.url = "github:nix-community/home-manager";
        home-manager.inputs.nixpkgs.follows = "nixpkgs";
    };

    outputs = inputs@{ self, nixpkgs, home-manager }: {
        nixosConfigurations = {
            juniper = nixpkgs.lib.nixosSystem {
                system = "x86_64-linux";
                specialArgs = { inherit inputs; };
                modules = [
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
                    ./yggdrasil/system.nix
                    home-manager.home-manager ./yggdrasil/home-manager.nix
                ];
            }
        };
    };
}