{ config, lib, pkgs, ... }:
{
  imports = [
    ./lightdm.nix
    ./graphical.nix
  ];

  services.displayManager.defaultSession = "sway";
  programs.sway = {
    enable = true;
    package = pkgs.swayfx-unwrapped;
    extraPackages = with pkgs; [
      swaybg
      swaylock
      grim
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gtk
      brightnessctl
      fuzzel
    ];
  }
}