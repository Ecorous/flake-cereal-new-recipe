{ config, lib, pkgs, ... }: 
{
    imports = [
        ./hardware.nix
        ../common/system.nix
        ../common/bluetooth.nix
        ../common/nvidia.nix
        ../common/plasma.nix
        ../common/virtualisation.nix
        # ../common/docker.nix
    ];

    programs.virt-manager.enable = true;
    
    virtualisation.podman = {
        enable = true;
        dockerCompat = true;
    };

    environment.systemPackages = with pkgs; [
        distrobox
    ];

    services.sunshine = {
        enable = true;
        capSysAdmin = true;
    };

    networking.hostName = "yggdrasil";
}
