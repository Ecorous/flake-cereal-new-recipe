{
  lib,
  pkgs,
  nushellWith,
  inputs,
  ...
}: {
  environment.systemPackages = [
    pkgs.nushell
  ];
}
