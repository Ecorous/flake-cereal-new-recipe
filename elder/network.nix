{ config, lib, pkgs, ... }:
{
  networking = {
    hostName = "elder";
    nameservers = [ "1.1.1.1" "1.0.0.1" ];
    interfaces = {
      wlp0s26u1u2.useDHCP = true;
      en0.useDHCP = false;

      en0 = {
        ipv4.addresses = [{
          address = "192.168.69.1";
          prefixLength = 24;
        }];
      };
      
    };
    ven0s = {
      wlp0s26u1u2 = {
        id = 10;
        interface = "wlp0s26u1u2";
      };
      en0 = {
        id = 20;
        interface = "en0";
      };
    };
    nat.enable = false;
    nftables = {
      enable = true;
      checkRuleset = false;
      ruleset = ''
      table inet filter {
        # enable flow offloading for better throughput
        flowtable f {
          hook ingress priority 0;
          devices = { wlp0s26u1u2, en0 };
        }

        chain output {
          type filter hook output priority 100; policy accept;
        }

        chain input {
          type filter hook input priority filter; policy drop;

          # Allow trusted networks to access the router
          iifname {
            "en0",
          } counter accept

          # Allow returning traffic from ppp0 and drop everthing else
          iifname "wlp0s26u1u2" ct state { established, related } counter accept
          iifname "wlp0s26u1u2" drop
        }

        chain forward {
          type filter hook forward priority filter; policy drop;

          # enable flow offloading for better throughput
          ip protocol { tcp, udp } flow offload @f

          # Allow trusted network wlp0s26u1u2 access
          iifname {
                  "en0",
          } oifname {
                  "wlp0s26u1u2",
          } counter accept comment "Allow trusted en0 to wlp0s26u1u2"

          # Allow established wlp0s26u1u2 to return
          iifname {
                  "wlp0s26u1u2",
          } oifname {
                  "en0",
          } ct state established,related counter accept comment "Allow established back to en0s"
        }
      }

      table ip nat {
        chain prerouting {
          type nat hook prerouting priority filter; policy accept;
        }

        # Setup NAT masquerading on the ppp0 interface
        chain postrouting {
          type nat hook postrouting priority filter; policy accept;
          oifname "wlp0s26u1u2" masquerade
        }
      }
    '';
    };
  };
  # services.dhcpd4 = {
  #   enable = true;
  #   interfaces = [ "en0" ];
  #   extraConfig = ''
  #     option domain-name-servers 1.1.1.1 1.0.0.1;
  #     option subnet-mask 255.255.255.0;

  #     subnet 192.168.69.0 netmask 255.255.255.0 {
  #       option broadcast-address 192.168.69.255;
  #       option routers 192.168.69.1;
  #       interface en0;
  #       range 192.168.69.2 192.168.69.254;
  #     }
  #   '';
  # };
  services.kea.dhcp4 = {
    enable = true;
    settings = {
      interfaces-config = {
        interfaces = [ "en0" ];
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
            data = "1.1.1.1"; 
          }
        ];
      }];
    };
  };
}