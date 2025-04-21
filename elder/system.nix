{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ../common/system.nix
    ../common/docker.nix
    ../common/virtualisation.nix
    ./network.nix
    ./caddy.nix
  ];

  boot.loader.systemd-boot.enable = false;
  boot.kernel.sysctl = {
    "net.ipv4.forward" = 1;
  };
  environment.systemPackages = with pkgs; [
    cloudflared
  ];
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
  };
  users.groups.smbaccu.gid = 7765;
  users.users = {
    david = {
      isNormalUser = true;
      extraGroups = [ "smbaccu"];
    };
    tirfarthoinn = {
      isNormalUser = true;
      extraGroups = [ "smbaccu" ];
    };
    noodle = {
      isNormalUser = true;
      extraGroups = [ "smbaccu" ];
    };
    hellholesys = {
      isNormalUser = true;
      extraGroups = [ "wheel" "smbaccu" "docker" ];
      shell = pkgs.fish;
    };
    nick = {
      isNormalUser = true;
      extraGroups = [ "wheel" "smbaccu" "docker" ];
      shell = pkgs.fish;
    };
    ecorous.extraGroups = [ "smbaccu" ];
  };

  programs.fish.enable = true;
  services.gvfs.enable = true; 
  services.udisks2.enable = true;

  services.cjdns = {
    enable = true;
    authorizedPasswords = [ "faggot" ];
    UDPInterface.bind = "0.0.0.0:33808";
  };

  services.cron = {
    enable = true;
    systemCronJobs = [
      "0 * * * *    root    . /etc/profile; ${pkgs.bash}/bin/bash /smb/cron.sh"
    ];
  };

  services.caddy.enable = true;

  services.samba = import ./samba.nix;
  services.samba-wsdd.enable = true;
  services.cloudflared = {
    enable = true;
    tunnels.jellyfin = {
      ingress = {
        "jellyfin.ecorous.org" = "http://localhost:8096";
        "jellyfin-vue.ecorous.org" = "http://localhost:8097";
        #default = "http_status:404";
        #credentialsFile = "/root/.cloudflared/bd0fa580-9dd0-4fa6-a3c4-79bac8c50f1f.json";
      };
      credentialsFile = "/root/.cloudflared/bd0fa580-9dd0-4fa6-a3c4-79bac8c50f1f.json";
      default = "http_status:404";
    };
  };
  services.jellyfin.enable = true;
}
