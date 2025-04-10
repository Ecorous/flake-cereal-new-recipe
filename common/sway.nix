{ config, lib, pkgs, ... }:
{
  imports = [
    ./sddm.nix
    ./graphical.nix
  ];

  services.displayManager.defaultSession = "sway";
  programs.sway = {
    enable = true;
    package = pkgs.swayfx;
    extraPackages = with pkgs; [
      swaybg
      swaylock-effects
      grim
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gtk
      brightnessctl
      fuzzel
      kdePackages.qt6ct
      kdePackages.breeze
      kdePackages.breeze-gtk
      kdePackages.breeze-icons
      nwg-look
    ];
  };
  environment.sessionVariables.QT_QPA_PLATFORMTHEME = "qt6ct";
  environment.sessionVariables.GTK_THEME = "Breeze-Dark";
  environment.sessionVariables.MOZ_ENABLE_WAYLAND = 0;
}
