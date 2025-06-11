{ lib, pkgs, fjordlauncher, inputs, inputs', ... }:
let
  inherit (pkgs.stdenv.hostPlatform) system;
in
{
  _module.args = {
    inputs' = lib.mapAttrs (_: lib.mapAttrs (_: attr: attr.${system} or attr)) inputs;
  };
  nix.settings = {
    trusted-substituters = [ "https://unmojang.cachix.org" ];

    trusted-public-keys = [
      "unmojang.cachix.org-1:OfHnbBNduZ6Smx9oNbLFbYyvOWSoxb2uPcnXPj4EDQY="
    ];
  };
  environment.systemPackages = [ (inputs'.fjordlauncher.packages.fjordlauncher.override {
    textToSpeechSupport = false;
  }) ];
}