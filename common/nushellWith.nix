{
  lib,
  pkgs,
  nushellWith,
  inputs,
  ...
}: {
  environment.systemPackages = [
    (nushellWith.packages.${pkgs.system}.nushell)
  ];
}
