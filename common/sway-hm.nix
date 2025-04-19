{ config, lib, pkgs, ... }:
{
  programs = {
    swaylock = {
      enable = true;
      package = null;
      settings = {
        grace = 2;
        # image = "/home/ecorous/lycorecowallpaper.png";
        image = "/run/current-system/sw/share/backgrounds/sway/Sway_Wallpaper_Blue_1920x1080.png";
        show-keyboard-layout = true;
        indicator-caps-lock = true;
        effect-blur = "50x10";
      };
    };
    ghostty.settings.background-opacity = 0.4;
  };

  wayland.windowManager.sway = { # FIXME this shouldn't be in global home-manager config. make a sway-hm file and import it additionally for each dsevice using the sway setup.
    enable = true;
    config = {
      menu = "fuzzel";
      modifier = "Mod4";
      terminal = "ghostty";
      output."*".bg = "/run/current-system/sw/share/backgrounds/sway/Sway_Wallpaper_Blue_1920x1080.png fill";
      # output."*".bg = "~/lycorecowallpaper.png fill";
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
          inactiveWorkspace = {
            background = "#323232aa";
            border = "#323232aa";
            text = "#5c5c5caa";
          };
        };
      }];
      keybindings = lib.mkOptionDefault {
        "Mod4+l" = "exec ${pkgs.swaylock-effects}/bin/swaylock";
        # "--locked XF86MonBrightnessDown" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set 1-";
        # "--locked XF86MonBrightnessUp" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set 1+";
        # "--locked XF86Tools" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set 0";
        "--locked XF86MonBrightnessDown" = "exec /home/ecorous/scripts/brightness_down.sh";
        "--locked XF86MonBrightnessUp" = "exec /home/ecorous/scripts/brightness_up.sh";
        "--locked XF86Tools" = "exec /home/ecorous/scripts/brightness_toggle.nu";
        "--locked XF86Search" = "exec /home/ecorous/scripts/brightness_set_1.sh";
      };
    };
    extraConfig = ''
    blur enable
    blur_xray enable
    corner_radius 5
    default_dim_inactive 0.25
    
    exec mako
    exec ghostty'';
    package = null;
  };
  services.mako = {
    enable = true;
    borderRadius = 7;
    defaultTimeout = 6000;
    layer = "overlay";
    extraConfig = '' 
    icon-border-radius=15
    '';
  };
  programs.fuzzel = {
    enable = true;
    settings = {
      colors = {
        background = "1e1e2edd";
        text = "cdd6f4ff";
        prompt = "bac2deff";
        placeholder = "7f849cff";
        input = "cdd6f4ff";
        match = "b4befeff";
        selection = "585b70ff";
        selection-text = "cdd6f4ff";
        selection-match = "b4befeff";
        counter = "7f849cff";
        border = "b4befeff";
      };
    };
  };
}
