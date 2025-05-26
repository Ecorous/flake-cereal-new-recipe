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
    waybar = {
      enable = true;
      settings = {
        main = {
          modules-left = [ "sway/workspaces" ];
          modules-center = [ "sway/window" ];
          modules-right = [ "backlight" "battery" "clock" "tray" ];

          "sway/workspaces" = {
            format = "{name}";
            all-outputs = true;
          };
          "sway/window" = {
            format = "{title}";
            max-length = 50;
          };
          backlight = {
            display = "intel_backlight";
            format = "{percent}%";
          };
          battery = {
            weighted-average = true;
          };
          clock = {
            interval = 1;
            format = "{:%F %T}";
          };
          tray = {
            show-passive-icons = true;
          };
        };
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
      bars = [];
      # bars = [{
      #   position = "top";
      #   statusCommand = "while date +[$(cat /sys/class/power_supply/BAT0/capacity)%]' [%Y-%m-%d %X]'; do sleep 1; done";
      #   colors = {
      #     statusline = "#ffffffff";
      #     background = "#323232ff";
      #     inactiveWorkspace = {
      #       background = "#323232aa";
      #       border = "#323232aa";
      #       text = "#5c5c5caa";
      #     };
      #   };
      # }];
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

    for_window {
      [app_id=".blueman-manager-wrapped"] move to workspace 10
      [app_id="com.mitchellh.ghostty"] move to workspace 1
      [class="vesktop"] move to workspace 2
      [class="Signal"] move to workspace 4
      [class="Element"] move to workspace 5
    }
   
    exec waybar
    exec mako
    exec blueman-manager
    exec vesktop
    exec signal-desktop
    exec element-desktop
    exec ghostty
    exec swaymsg workspace 1'';
    package = null;
  };
  services.mako = {
    enable = true;
    settings = {
      max-visible = 5;
      max-history = 5;
      sort = "-time";
      layer = "overlay";
      anchor = "top-right";
      font = "monospace 10";
      background-color = "#285577ff";
      text-color = "#ffffffff";
      width = 300;
      height = 100;
      margin = 10;
      padding = 5;
      border-size = 1;
      border-color = "#4c7899ff";
      border-radius = 7;
      progress-color = "over #5588aaff";
      icons = true;
      max-icon-size = 64;
      markup = true;
      actions = true;
      format = "<b>%s</b>\\n%b";
      default-timeout = 6000;
      icon-border-radius = 15;
    };
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
