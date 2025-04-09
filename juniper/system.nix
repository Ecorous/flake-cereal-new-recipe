{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ../common/system.nix 
    ../common/sway.nix
    ../common/bluetooth.nix
  ];

  programs = [];

  environment.systemPackages = with pkgs; [];

  hardware.graphics.extraPackages = [ pkgs.intel-media-driver ];

  networking.hostName = "juniper";
}