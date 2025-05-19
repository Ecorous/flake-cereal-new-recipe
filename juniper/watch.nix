{ config, lib, pkgs, ... }:
{
  home.stateVersion = "24.11";

  home.username = "watch";
  home.homeDirectory = "/home/watch";
  home.file = {
    ".ssh/authorized_keys".source = ../files/authorized_keys;
    ".ssh/auth.pub".source = ../files/auth.pub;
  };

  programs = {
    home-manager.enable = true;
    nushell = {
      enable = true;
      configFile.source = ../files/config.nu;
    };

    swaylock = {
      enable = true;
      package = null;
      settings = {
        grace = 2;
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
          modules-center = [ "sway/window" ];
          modules-right = [ "backlight" "battery" "clock" ];

          "sway/window" = {
            format = "{title}";
            max-length = 50;
          };

          backlight = {
            display = "intel_backlight";
            format = "brightness: {percent}%";
          };
          battery = {
            weighted-average = true;
          };
          clock = {
            interval = 1;
            format = "{:%F %T}";
          };
        };
      };
    };
  };
  wayland.windowManager.sway = {
    enable = true;
    config = {
      menu = "fuzzel";
      modifier = "Mod4";
      terminal = "ghostty";
      output."*".bg = "/run/current-system/sw/share/backgrounds/sway/Sway_Wallpaper_Blue_1920x1080.png fill";
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

      keybindings = lib.mkOptionDefault {
        "--locked XF86MonBrightnessDown" = "exec /home/watch/scripts/brightness_down.sh";
        "--locked XF86MonBrightnessUp" = "exec /home/watch/scripts/brightness_up.sh";
        "--locked XF86Tools" = "exec /home/watch/scripts/brightness_toggle.nu";
        "--locked XF86Search" = "exec /home/watch/scripts/brightness_set_1.sh";
      };

  };
  extraConfig = ''
    blur enable
    blur_xray enable
    corner_radius 5
    default_dim_inactive 0.1
    
    for_window {
      [app_id=".blueman-manager-wrapped"] move to workspace 4
      [app_id="mpv"] move to workspace 1
      [app_id="com.mitchellh.ghostty"] move to workspace 2
      [app_id="com.saivert.pwvucontrol"] move to workspace 3
      [app_id="org.kde.dolphin"] move to workspace 5
      [app_id="org.gnome.Nautilus"] move to workspace 5
    }
      
    exec waybar
    exec blueman-manager
    exec pwvucontrol
    exec nautilus /srv/watch
    exec ghostty
    exec bluetoothctl connect B0:38:E2:3B:0F:BF
    exec bluetoothctl connect B0:38:E2:6E:00:38

    exec nu -c "pactl load-module module-combine-sink; sleep 1sec; pactl set-default-sink combined"
    exec nu -c "sleep 2sec; swaymsg workspace 5'';
    package = null;
  };

  home.file."scripts/brightness_down.sh".source = ../files/brightness_down.sh;
  home.file."scripts/brightness_down.sh".executable = true;
  home.file."scripts/brightness_up.sh".source = ../files/brightness_up.sh;
  home.file."scripts/brightness_up.sh".executable = true;
  home.file."scripts/brightness_set_1.sh".source = ../files/brightness_set_1.sh;
  home.file."scripts/brightness_set_1.sh".executable = true;
  home.file."scripts/brightness_toggle.nu".source = ../files/brightness_toggle.nu;
  home.file."scripts/brightness_toggle.nu".executable = true;
  home.file."scripts/mpv_wrapper.sh".source = ../files/mpv_wrapper.sh;
  home.file."scripts/mpv_wrapper.sh".executable = true;
}