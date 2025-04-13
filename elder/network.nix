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
    services.dnsmasq = {
    enable = true;
    alwaysKeepRunning = true;
    extraConfig = ''
      interface=br0
      domain=elder,192.168.69.1
      # ^ Domain and Address of the host.
      dhcp-range=192.168.69.5,192.168.69.254,5m
      # ^ All IP addresses between that range will be handed out with a 5 minute lease time.
      # It also reserves the first 10 addresses for static IP's.
      dhcp-option=3,192.168.69.1
      # ^ This is the primary DNS. DNSMasq will also be the DNS server, 
      # since it can cache. You can point this wherever you wish.
      dhcp-option=121,192.168.69.0/24.192.168.69.1
      # ^ This is a classless static route. I'm not 100% sure what it does, 
      # but things seem to work better with it. Apparently Windows ignores this.
      
      # From here you can set up static IP's for your devices, if you want.
      # dhcp-host:AA:BB:CC:DD:EE:FF,10.0.0.2
      # Repeat as needed.
      
      # DNS
      listen-address=1,127.0.0.1,10.0.0.1
      # It listens on both the local and the bridge interface.
      expand-hosts
      # This will allow you to refer to devices by their hostname.
      server=1.1.1.1  
      # ^ This is Cloudflare's DNS server. You can use whatever you want.
      server=1.0.0.1
      address=/elder.int/192.168.69.1
      # ^ This is a static DNS entry. It will resolve example.com to 10.0.0.1, or in other words, the router.
    '';
  };
}