{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ../common/system.nix 
    ../common/sway.nix
    ../common/bluetooth.nix

  ];

  environment.systemPackages = [
    pkgs.nautilus
  ];

  users.users.watch = {
    description = "Watching";
    isNormalUser = true;
    shell = pkgs.nushell;
  };
  # services.desktopManager.plasma6.enable = true; # we don't actually use this, just want the packages


  hardware.graphics.extraPackages = [ pkgs.intel-media-driver ];

  networking.hostName = "juniper";
}