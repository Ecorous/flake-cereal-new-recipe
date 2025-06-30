{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./hardware.nix
    ../common/system.nix 
    ../common/sway.nix
    ../common/plasma.nix
    # ../common/gnome.nix
    ../common/bluetooth.nix
  ];

  services.displayManager.defaultSession = lib.mkForce "plasma";

  environment.systemPackages = with pkgs; [
    nautilus
    brightnessctl
    adwaita-icon-theme
    adwaita-icon-theme-legacy
    gnome-themes-extra
    gnomeExtensions.tray-icons-reloaded
  ];

  users.users.watch = {
    description = "Watching";
    isNormalUser = true;
    shell = pkgs.nushell;
  };

  services.displayManager.sddm.enable = lib.mkForce true;
  services.displayManager.gdm.enable = lib.mkForce false;
  qt.style = lib.mkForce "breeze";
  qt.platformTheme = lib.mkForce "kde6";



  hardware.graphics.extraPackages = [ pkgs.intel-media-driver ];

  networking.hostName = "juniper";
}
