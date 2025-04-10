{ config, lib, pkgs, ... }: 
{
  imports = [
    ./sddm.nix
    ./graphical.nix
  ];

  services.desktopManager.plasma6.enable = true;
  services.displayManager.defaultSession = "plasma";
}