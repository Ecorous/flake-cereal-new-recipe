{ config, lib, pkgs, ... }: 
{
    imports = [
        ./hardware.nix
        ../common/system.nix
        ../common/bluetooth.nix
        ../common/nvidia.nix
        ../common/plasma.nix
    ];

    networking.hostName = "yggdrasil";
}