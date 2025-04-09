{ pkgs, ... }:
{
  services.xserver.displayManager.lightdm = {
    greeters.slick = {
      enable = true;
      theme = {
        name = "Breeze-Dark";
        package = pkgs.kdePackages.breeze;
      };
      iconTheme = {
        name = "breeze-dark";
        package = pkgs.kdePackages.breeze;
      };
      font = {
        name = "Fira Code";
        package = pkgs.fira-code;
      };
      extraConfig = ''
      content-align=center
      background=/usr/share/backgrounds/lycorecowallpaper.png
      '';
    };
  };
}