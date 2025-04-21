{ config, lib, pkgs, ... }:
{
  networking = {
    hostName = "elder";
    bridges = {
      br0 = {
        interfaces = [ "eno1" ];
      };
    };

    nat = {
      enable = true;
      externalInterface = "wlp0s26u1u2";
      internalInterfaces = [ "br0" ];
      internalIPs = [ "192.168.69.0/24" ];
    };
    
    interfaces = {
      "wlp0s26u1u2" = {
        useDHCP = true;
        tempAddress = "disabled";
      };
      "br0" = {
        ipv4.addresses = [ { address = "192.168.69.1"; prefixLength = 24; } ];
        useDHCP = false;
      };
    };
  };

  services.hostapd = {
    enable = false;
    radios.wlp0s26u1u2 = {
      # band = "5g";
      # channel = 36;
      networks.wlp0s26u1u2 = {
        ssid = "crotchgoblins";
        authentication.mode = "wpa2-sha256";
        # authentication.wpaPassword = builtins.readFile ./passphrase;
      };
    };
  };

  #   interfaces = {
  #     wlp0s26u1u2.useDHCP = true;
  #     eno1.useDHCP = false;

  #     eno1 = {
  #       ipv4.addresses = [{
  #         address = "192.168.69.1";
  #         prefixLength = 24;
  #       }];
  #     };
      
  #   };
  #   nat.enable = false;
  #   nftables = {
  #     enable = false;
  #     checkRuleset = false;
  #     ruleset = ''
  #     table inet filter {
  #       # enable flow offloading for better throughput
  #       flowtable f {
  #         hook ingress priority 0;
  #         devices = { wlp0s26u1u2, eno1 };
  #       }

  #       chain output {
  #         type filter hook output priority 100; policy accept;
  #       }

  #       chain input {
  #         type filter hook input priority filter; policy drop;

  #         # Allow trusted networks to access the router
  #         iifname {
  #           "eno1",
  #         } counter accept

  #         # Allow returning traffic from ppp0 and drop everthing else
  #         iifname "wlp0s26u1u2" ct state { established, related } counter accept
  #         iifname "wlp0s26u1u2" drop
  #       }

  #       chain forward {
  #         type filter hook forward priority filter; policy drop;

  #         # enable flow offloading for better throughput
  #         ip protocol { tcp, udp } flow offload @f

  #         # Allow trusted network wlp0s26u1u2 access
  #         iifname {
  #                 "eno1",
  #         } oifname {
  #                 "wlp0s26u1u2",
  #         } counter accept comment "Allow trusted eno1 to wlp0s26u1u2"

  #         # Allow established wlp0s26u1u2 to return
  #         iifname {
  #                 "wlp0s26u1u2",
  #         } oifname {
  #                 "eno1",
  #         } ct state established,related counter accept comment "Allow established back to eno1s"
  #       }
  #     }

  #     table ip nat {
  #       chain prerouting {
  #         type nat hook prerouting priority filter; policy accept;
  #       }

  #       # Setup NAT masquerading on the ppp0 interface
  #       chain postrouting {
  #         type nat hook postrouting priority filter; policy accept;
  #         oifname "wlp0s26u1u2" masquerade
  #       }
  #     }
  #   '';
  #   };
  # };
  # # services.dhcpd4 = {
  # #   enable = true;
  # #   interfaces = [ "eno1" ];
  # #   extraConfig = ''
  # #     option domain-name-servers 1.1.1.1 1.0.0.1;
  # #     option subnet-mask 255.255.255.0;

  # #     subnet 192.168.69.0 netmask 255.255.255.0 {
  # #       option broadcast-address 192.168.69.255;
  # #       option routers 192.168.69.1;
  # #       interface eno1;
  # #       range 192.168.69.2 192.168.69.254;
  # #     }
  # #   '';
  # # };
  # services.kea.dhcp4 = {
  #   enable = true;
  #   settings = {
  #     interfaces-config = {
  #       interfaces = [ "eno1" ];
  #     };
  #     subnet4 = [{
  #       id = 1;
  #       subnet = "192.168.69.0/24";
  #       pools = [ { pool = "192.168.69.2 - 192.168.69.254"; } ];
  #       option-data = [
  #         {
  #           name = "routers";
  #           data = "192.168.69.1";
  #         }

  #         {
  #           name = "domain-name-servers";
  #           data = "1.1.1.1"; 
  #         }
  #       ];
  #     }];
  #   };
  # };
  networking.dhcpcd.enable = lib.mkForce false;
  services.dnsmasq = {
    enable = true;
    alwaysKeepRunning = true;
    settings = {
      interface = "br0";
      domain = "elder,192.168.69.1";
      dhcp-range = "192.168.69.5,192.168.69.254,5m";
      dhcp-option = [
        "3,192.168.69.1"
        "121,192.168.69.0/24,192.168.69.1"
        "66,192.168.69.1"
      ];
      dhcp-host = [ "60:cf:84:84:7f:2e,192.168.69.2" "00:19:99:a0:55:4e,192.168.69.3" "94:de:80:c3:cd:5e,192.168.69.4" ];
      listen-address = [ "127.0.0.1" "192.168.69.1" "192.168.1.242" "0.0.0.0" ];
      expand-hosts = true;
      server = [
        "1.1.1.1"
        "1.0.0.1"
      ];
      address = [ "/elder.int/192.168.69.1" "/jellyfin.elder.int/192.168.69.1" "/jf.elder.int/192.168.69.1" "/yggdrasil.int/192.168.69.2" "/files.yggdrasil.int/192.168.69.2" "/raffle.int/192.168.69.3" "/win10.int/192.168.69.4" ];
      enable-tftp = true;
      tftp-root = "/srv/tftp";
      dhcp-boot = "netboot.xyz.kpxe";
    };
  };
}