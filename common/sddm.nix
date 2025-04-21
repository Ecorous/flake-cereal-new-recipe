{ pkgs, lib, ... }:
{
  environment.systemPackages = [
    pkgs.kdePackages.plasma-desktop
  ];
  services.displayManager.sddm = {
    enable = true;
    package = lib.mkForce pkgs.kdePackages.sddm;
    wayland.enable = true;
    extraPackages = with pkgs.kdePackages; [
      plasma-desktop
      breeze-icons
      kirigami
      libplasma
      plasma5support
      qtsvg
      qtvirtualkeyboard
    ];
    settings = {
      Theme = {
        Current = "breeze";
        # ThemeDir = lib.mkForce "/sddm_themes";
      };
      #"Background" = "/usr/share/backgrounds/lycorecowallpaper.png";
    };
  };
}
