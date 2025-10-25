{
  lib,
  pkgs,
  nushellWith,
  inputs,
  ...
}: let pkgs = import pkgs {
    system = "x86_64-linux";
    overlays = [ nushellWith.overlays.default ];
  }; in {
  environment.systemPackages = [
    pkgs.nushell
  ];
}
