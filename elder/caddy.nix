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
        serverAliases = [ 
          "https://jellyfin.elder.ext"
          "https://jf.elder.int"
          "https://jf.elder.ext"
          "https://jellyfin.ecorous.org"
          "https://jf.ecorous.org"
          "http://jf.elder.int"
          "http://jf.elder.ext"
          "http://jellyfin.elder.int"
          "http://jellyfin.elder.ext"
          "http://jellyfin.ecorous.org"
          "http://jf.ecorous.org"
        ];
        extraConfig = ''
          reverse_proxy localhost:8096
        '';
      };
      "http://wol.elder.int" = {
        serverAliases = [ "https://wol.elder.int" "http://wol.elder.ext" "https://wol.elder.ext" ];
        extraConfig = ''
          redir / /wolweb 302
          reverse_proxy localhost:8089
        '';
      };
      "http://jellystat.elder.int" = {
        serverAliases = [ "https://jellystat.elder.int" "http://jellystat.elder.ext" "https://jellystat.elder.ext" ];
        extraConfig = ''
          reverse_proxy localhost:3000
        '';
      };
      "http://elder.int" = {
        serverAliases = [ "https://elder.int" "http://elder.ext" "https://elder.ext" ];
        extraConfig = ''
          root /srv/www
          file_server  
        '';
      };
    };
  };
}