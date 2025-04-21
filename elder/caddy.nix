{ config, lib, pkgs, ... }:
{
  services.caddy = {
    enable = true;
    globalConfig = ''
      local_certs
      auto_https disable_redirects
    '';
    virtualHosts = {
      "https://jellyfin.elder.int" = {
        serverAliases = [ "https://jf.elder.int" "https://jellyfin.ecorous.org" "https://jf.ecorous.org" "http://jf.elder.int" "http://jellyfin.elder.int" "http://jellyfin.ecorous.org" "http://jf.ecorous.org" ];
        extraConfig = ''
          reverse_proxy localhost:8096
        '';
      };
    };
  };
}