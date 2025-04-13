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
    nat.enable = false;
    nftables = {
      enable = true;
      ruleset = ''
      table inet filter {
        # enable flow offloading for better throughput
        flowtable f {
          hook ingress priority 0;
          devices = { wan, lan };
        }

        chain output {
          type filter hook output priority 100; policy accept;
        }

        chain input {
          type filter hook input priority filter; policy drop;

          # Allow trusted networks to access the router
          iifname {
            "lan",
          } counter accept

          # Allow returning traffic from ppp0 and drop everthing else
          iifname "wan" ct state { established, related } counter accept
          iifname "wan" drop
        }

        chain forward {
          type filter hook forward priority filter; policy drop;

          # enable flow offloading for better throughput
          ip protocol { tcp, udp } flow offload @f

          # Allow trusted network WAN access
          iifname {
                  "lan",
          } oifname {
                  "wan",
          } counter accept comment "Allow trusted LAN to WAN"

          # Allow established WAN to return
          iifname {
                  "wan",
          } oifname {
                  "lan",
          } ct state established,related counter accept comment "Allow established back to LANs"
        }
      }

      table ip nat {
        chain prerouting {
          type nat hook prerouting priority filter; policy accept;
        }

        # Setup NAT masquerading on the ppp0 interface
        chain postrouting {
          type nat hook postrouting priority filter; policy accept;
          oifname "wan" masquerade
        }
      }
    '';
    };
  };
  # services.dhcpd4 = {
  #   enable = true;
  #   interfaces = [ "lan" ];
  #   extraConfig = ''
  #     option domain-name-servers 1.1.1.1 1.0.0.1;
  #     option subnet-mask 255.255.255.0;

  #     subnet 192.168.69.0 netmask 255.255.255.0 {
  #       option broadcast-address 192.168.69.255;
  #       option routers 192.168.69.1;
  #       interface lan;
  #       range 192.168.69.2 192.168.69.254;
  #     }
  #   '';
  # };
  services.kea.dhcp4 = {
    enable = true;
    settings = {
      interfaces-config = {
        interfaces = [ "lan" ];
      };
      subnet4 = [{
        id = 1;
        subnet = "192.168.69.0/24";
        pools = [ { pool = "192.168.69.2 - 192.168.69.254"; } ];
        option-data = [
          {
            name = "routers";
            data = "192.168.69.1";
          }

          {
            name = "domain-name-servers";
            data = [ "1.1.1.1" "1.0.0.1" ]; 
          }
        ];
      }];
    };
  };
}