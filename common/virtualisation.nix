{ config, lib, pkgs, ... }: {
  #programs.virt-manager.enable = true;
  users.groups.libvirtd.members = [ "ecorous" ];
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;
}
