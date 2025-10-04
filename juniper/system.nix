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
    ../common/hyprland.nix
    ../common/plasma.nix
    # ../common/gnome.nix
    ../common/bluetooth.nix
  ];

  services.displayManager.defaultSession = lib.mkForce "hyprland";

  environment.systemPackages = with pkgs; [
    nautilus
    brightnessctl
    adwaita-icon-theme
    adwaita-icon-theme-legacy
    swaylock-effects
    # gnome-themes-extra
    # gnomeExtensions.tray-icons-reloaded
  ];

  # users.users.watch = {
  #   description = "Watching";
  #   isNormalUser = true;
  #   shell = pkgs.nushell;
  # };

  services.displayManager.sddm.enable = lib.mkForce true;
  services.displayManager.gdm.enable = lib.mkForce false;
  qt.style = lib.mkForce "breeze";
  qt.platformTheme = lib.mkForce "qt5ct";

  hardware.graphics.extraPackages = [ pkgs.intel-media-driver ];

  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "ignore";
  };
  
  networking.hostName = "juniper";
}
