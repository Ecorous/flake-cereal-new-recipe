{ config, lib, pkgs, ... }:
{
  home.stateVersion = "24.11";

  home.username = "ecorous";
  home.homeDirectory = "/home/ecorous";

  programs = {
    home-manager.enable = true;
    ssh = {
      enable = true;
      matchBlocks."*" = {
        extraOptions = {
          GatewayPorts = "yes";
          IdentityAgent = "~/.1password/agent.sock";
        };
      };
      matchBlocks."github.com" = {
        hostname = "github.com";
        user = "git";
      };
    };
    btop.enable = true;
    helix.enable = true;
    ghostty = {
      enable = true;
      settings.theme = "catppuccin-mocha";
    };
    git = {
      enable = true;
      userEmail = "ecorous@outlook.com";
      userName = "Ecorous";
      extraConfig = {
        commit.gpgSign = true;
        gpg.format = "ssh";
        user.signingkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIazU90lTF7rPY11hzMA2CdOXmdaOBTZWJ25PBDl1gzS";
        "gpg \"ssh\"".program = "${lib.getExe' pkgs._1password-gui "op-ssh-sign"}";
      };
    };
    nushell = {
      enable = true;
      configFile.source = ../files/nushell/config.nu;
    }
  };
  
  services = {
    kdeconnect = {
      enable = true;
      indicator = true;
    };
  };

  home.file = {
    "lycorecowallpaper.png".source = ../files/lycorecowallpaper.png;
    # ".ssh/authorized_keys".source = ../files/authorized_keys;
    ".ssh/auth.pub".source = ../files/auth.pub;
  };
}
