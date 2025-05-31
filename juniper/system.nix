{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ../common/system.nix 
    # ../common/sway.nix
    ../common/plasma.nix
    ../common/bluetooth.nix

  ];

  environment.systemPackages = with pkgs; [
    nautilus
    brightnessctl
  ];

  users.users.watch = {
    description = "Watching";
    isNormalUser = true;
    shell = pkgs.nushell;
  };


  hardware.graphics.extraPackages = [ pkgs.intel-media-driver ];

  networking.hostName = "juniper";
}