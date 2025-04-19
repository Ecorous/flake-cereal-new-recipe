{ config, lib, pkgs, ... }:
{
  imports = [
    <nixos-wsl/modules>
    ../common/system.nix
  ];

  wsl.enable = true;
  wsl.defaultUser = "ecorous";
}