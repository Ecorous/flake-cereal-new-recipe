{ config, lib, pkgs, ... }:
{
  imports = [
    <nixos-wsl/modules>
    ../common/system.nix
  ];

  wsl.enable = true;
  wsl.defaultUser = "ecorous"; 
  wsl.useWindowsDriver = true; # Use OpenGL driver from Windows
  wsl.wslConf.user.default = "ecorous";
  

  networking.hostname = "wsl";
}