{ config, lib, pkgs, ... }:

{
  imports = [
    # ./sddm.nix
    ./graphical.nix
  ];
  services.displayManager.gdm = {
    enable = true;
    wayland = true;
  };
  services.desktopManager.gnome.enable = true;
  # services.displayManager.defaultSession = lib.mkDefault "gnome";
  services.gnome = {
    sushi.enable = true;
    gnome-settings-daemon.enable = true;
    gnome-remote-desktop.enable = true;
    gnome-keyring.enable = true;
    gnome-browser-connector.enable = true;
    core-shell.enable = true;
    core-os-services.enable = true;
    core-apps.enable = true;
    glib-networking.enable = true;
    games.enable = true;
  };
}
