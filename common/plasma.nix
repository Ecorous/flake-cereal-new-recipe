{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./sddm.nix
    ./graphical.nix
  ];

  services.desktopManager.plasma6.enable = true;
  # services.displayManager.defaultSession = lib.mkDefault "plasma";
<<<<<<< HEAD
}
=======
}
>>>>>>> 0938a866a31de7f98db4a8b129b2e76057fae2a2
