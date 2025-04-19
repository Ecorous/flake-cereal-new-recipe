{ config, lib, pkgs, ... }:
{
  imports = [
    ../common/ecorous.nix
    ../common/sway-hm.nix
  ];

  home.file."scripts/brightness_down.sh".source = ../files/brightness_down.sh;
  home.file."scripts/brightness_down.sh".executable = true;
  home.file."scripts/brightness_up.sh".source = ../files/brightness_up.sh;
  home.file."scripts/brightness_up.sh".executable = true;
  home.file."scripts/brightness_set_1.sh".source = ../files/brightness_set_1.sh;
  home.file."scripts/brightness_set_1.sh".executable = true;
  home.file."scripts/brightness_toggle.nu".source = ../files/brightness_toggle.nu;
  home.file."scripts/brightness_toggle.nu".executable = true;
}
