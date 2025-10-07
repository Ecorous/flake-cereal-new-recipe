{ config, lib, pkgs, ... }:
{
  programs.hyprland.enable = true;
  environment.systemPackages = with pkgs; [
    fuzzel
    brightnessctl
    nwg-look
    networkmanagerapplet
    playerctl
    libadwaita
    gnome-themes-extra
    gtk-engine-murrine
    dissent
  ];
  environment.sessionVariables.GTK_THEME = "Adwaita-dark";
  security.pam.services.hyprlock = {};
}
