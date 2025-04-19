{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ]; 
  boot.kernelModules = [ "kvm-intel "];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/juniperRoot"; # FIXME - I don't know what this is yet - need to investigate with a proper live usb. this is just a draft
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/juniperBoot"; # FIXME - same as above
    fsType = "vfat";
    options = [ "fmask=0022" "dmask=0022" ];
  };

  swapDevices = [{
    label = "linuxswap";
  }];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = 
    lib.mkDefault true;
}