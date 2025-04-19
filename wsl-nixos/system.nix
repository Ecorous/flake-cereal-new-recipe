{ config, lib, pkgs, ... }:
{
  imports = [
    ../common/system.nix
  ];

  boot.loader.systemd-boot.enable = lib.mkForce false;

  wsl.enable = true;
  wsl.defaultUser = "ecorous"; 
  wsl.useWindowsDriver = true; # Use OpenGL driver from Windows
  wsl.wslConf.user.default = "ecorous";


  networking.hostName = "wsl-nixos";
}