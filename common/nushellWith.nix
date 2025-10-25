{
  lib,
  pkgs,
  nushellWith,
  inputs,
  ...
}: let pkgs = import nixpkgs {
    system = "x86_64-linux";
    overlays = [ nushellWith.overlays.default ];
  }; in {
  environment.systemPackages = [
    pkgs.nushell
  ];
}
