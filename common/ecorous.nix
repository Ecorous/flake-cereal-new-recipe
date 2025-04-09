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
        };
      };
    };
    btop.enable = true;
    helix.enable = true;
    ghostty = {
      enable = true;
      settings.theme = "catppuccin-mocha";
      background-opacity = 0.4;
    };
    git = {
      "github.com" = {
        hostname = "github.com";
        user = "git";
      };
      "*" = {
        extraOptions = { IdentityAgent = "~/.1password/agent.sock"; }
      };
    }; 
    swaylock = {
      enable = true;
      settings = {
        grace = 2;
        image = "/home/ecorous/lycorecowallpaper.png";
        show-keyboard-layout = "";
        indicator-caps-lock = "";
      };
    };
  };
  wayland.windowManager.sway = { # FIXME this shouldn't be in global home-manager config. make a sway-hm file and import it additionally for each dsevice using the sway setup.
    enable = true;
    config = {
      menu = "fuzzel";
      modifier = "Mod4";
      terminal = "ghostty";
      output."*".bg = "~/lycorecowallpaper.png fill";
      input = {
        "type:keyboard" = {
          xkb_layout = "gb";
        };
        "2:7:SynPS/2_Synaptics_TouchPad" = {
          dwt = "disabled";
          tap = "enabled";
          natural_scroll = "enabled";
        };
      };
      bars = [{
        position = "top";
        statusCommand = "while date +[$(cat /sys/class/power_supply/BAT0/capacity)%]' [%Y-%m-%d %X]'; do sleep 1; done";
        colors = {
          statusline = "#ffffffff";
          background = "#323232ff";
          inactive_workspaces = "#323232aa #323232aa #5c5c5caa";
        };
      }];
    };
    extraConfig = ''
    blur enable
    blur_xray enable
    corner_radius 5
    default_dim_inactive 0.25
    
    exec mako'';
    package = null;
  };
  services = {
    kdeconnect = {
      enable = true;
      indicator = true;
    };
    mako = {
      enable = true;
      borderRadius = 7;
      defaultTimeout = 6000;
      layer = "overlay";
      extraConfig = ''
      icon-border-radius=15
      '';
    };
    flameshot.enable = true;
  };

  home.file = {
    "lycorecowallpaper.png".source = ../files/lycorecowallpaper.png;
    ".ssh/authorized_keys".source = ../files/authorized_keys;
    ".ssh/auth.pub".source = ../files/auth.pub;
  };
}