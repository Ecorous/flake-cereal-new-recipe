{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.kernelModules = [ "kvm-intel "];
  # TODO - put actual hardware config in here by using the live
  # TODO   environemnt, this is just an estimated config 

  fileSystems."/" = {
    device = "/dev/disk/by-label/juniperRoot"; # FIXME - I don't know what this is yet - need to investigate with a proper live usb. this is just a draft
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/juniperBoot"; # FIXME - same as above
    fsType = "vfat";
  };

  swapDevices = [{
    label = "linuxswap";
  }];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = 
    lib.mkDefault config.hardware.allowRedistributableFirmware;
}