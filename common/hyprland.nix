{ config, lib, pkgs, ... }:
{
  programs.hyprland.enable = true;
  environment.systemPackages = with pkgs; [
    fuzzel
    brightnessctl
    nwg-look
    networkmanagerapplet
    
  ];
  security.pam.services.hyprlock = {};
}
