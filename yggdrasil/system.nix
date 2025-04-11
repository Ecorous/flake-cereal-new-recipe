{ config, lib, pkgs, ... }: 
{
    imports = [
        ./hardware.nix
        ../common/system.nix
        ../common/bluetooth.nix
        ../common/nvidia.nix
        ../common/plasma.nix
        # ../common/docker.nix
    ];

    virtualisation.podman = {
        enable = true;
        dockerCompat = true;
    };

    environment.systemPackages = with pkgs; [
        distrobox
    ];

    services.sunshine.enable = true;

    networking.hostName = "yggdrasil";
}