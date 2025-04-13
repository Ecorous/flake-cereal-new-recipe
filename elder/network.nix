{ config, lib, pkgs, ... }:
{
  networking = {
    hostName = "elder";
    nameservers = [ "1.1.1.1" "1.0.0.1" ];
    interfaces = {
      wlp0s26u1u2.useDHCP = true;
      en0.useDHCP = false;

      lan = {
        ipv4.addresses = [{
          address = "192.168.69.1";
          prefixLength = 24;
        }];
      };
      
    };
    vlans = {
      wan = {
        id = 10;
        interface = "wifi";
      };
      lan = {
        id = 20;
        interface = "eth";
      };
    };
  };
}