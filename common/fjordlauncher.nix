<<<<<<< HEAD
{ lib, pkgs, fjordlauncher, inputs, inputs', ... }:
=======
{
  lib,
  pkgs,
  fjordlauncher,
  inputs,
  inputs',
  ...
}:
>>>>>>> 0938a866a31de7f98db4a8b129b2e76057fae2a2
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
<<<<<<< HEAD
  environment.systemPackages = [ (inputs'.fjordlauncher.packages.fjordlauncher.override {
    textToSpeechSupport = false;
  }) ];
}
=======
  environment.systemPackages = [
    (inputs'.fjordlauncher.packages.fjordlauncher.override {
      textToSpeechSupport = false;
    })
  ];
}
>>>>>>> 0938a866a31de7f98db4a8b129b2e76057fae2a2
