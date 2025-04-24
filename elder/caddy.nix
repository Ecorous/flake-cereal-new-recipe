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
          "https://jellyfin.elder.ex"
          "https://jf.elder.int"
          "https://jf.elder.ex"
          "https://jellyfin.ecorous.org"
          "https://jf.ecorous.org"
          "http://jf.elder.int"
          "http://jf.elder.ex"
          "http://jellyfin.elder.int"
          "http://jellyfin.elder.ex"
          "http://jellyfin.ecorous.org"
          "http://jf.ecorous.org"
        ];
        extraConfig = ''
          reverse_proxy localhost:8096
        '';
      };
      "http://wol.elder.int" = {
        serverAliases = [ "https://wol.elder.int" "http://wol.elder.ex" "https://wol.elder.ex" ];
        extraConfig = ''
          redir / /wolweb 302
          reverse_proxy localhost:8089
        '';
      };
      "http://jellystat.elder.int" = {
        serverAliases = [ "https://jellystat.elder.int" "http://jellystat.elder.ex" "https://jellystat.elder.ex" ];
        extraConfig = ''
          reverse_proxy localhost:3000
        '';
      };
    };
  };
}