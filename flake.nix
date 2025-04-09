{
    description = "Flake Cereal - Brand new recipe!";

    input = {
        nixpkgs.url = "github:nixos/nixpkgs/nixpks?ref=nixos-unstable";
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
        }
    };
}