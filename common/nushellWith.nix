{
  lib,
  pkgs,
  nushellWith,
  inputs,
  ...
}: let pkgs = import nixpkgs {
    system = ${pkgs.system};
    overlays = [ nushellWith.overlays.default ];
  }; in {
  environment.systemPackages = [
    pkgs.nushell
  ];
}
