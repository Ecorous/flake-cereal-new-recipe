{ config, libs, pkgs, ... }:
{
  virtualisation.docker.enable = true;
  users.extraGroups.docker.members = [ "ecorous" ];
}