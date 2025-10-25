{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs = {
    waybar = {
      enable = true;
      settings = {
        main = {
          modules-left = [ "hyprland/workspaces" ];
          modules-center = [ "hyprland/window" "custom/music" ];
          modules-right = [
            "backlight"
            "battery"
            "clock"
            "tray"
          ];

          "hyprland/workspaces" = {
            format = "{name}";
            all-outputs = true;
          };
          "hyprland/window" = {
            format = "{title}";
            max-length = 50;
          };
          "custom/music" = {
            # "format": "  {}",
            #         "escape": true,
            #                 "interval": 5,
            #                         "tooltip": false,
            #                                 "exec": "playerctl metadata --format='{{ title }}'",
            #                                         "on-click": "playerctl play-pause",
            #                                                 "max-length": 50

            format = " {}";
            escape = true;
            interval = 5;
            tooltip = false;
            exec = "playerctl metadata --format='{{ title }}'";
            on-clickc = "playerctl play-pause";
            max-length = 50;
          };
          backlight = {
            display = "intel_backlight";
            format = "{percent}%";
          };
          # 
        # "battery": {
        #   "states": {
        #     "warning": 30,
        #     "critical": 15
        #   },    
        #   "format": "{icon}",
        #   "format-charging": "",
        #   "format-plugged": "",
        #   "format-alt": "{icon}",
        #   "format-icons": ["", "",  "", "", "", "", "", "", "", "", "", ""]
        # }
        
          battery = {
            weighted-average = true;
            states = {
              warning = 30;
              critical = 15;
            };
            format = "{capacity}%";
            format-warning = "warning {capacity}%";
            format-critical = "plug me in 🥺 {capacity}%";
                        # format-icons = ["" "" "" "" "" "" "" "" "" "" "" ""];
            # format-charging = "";
            # format-plugged = "";
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
      style = ''
        @import "mocha.css";
        
        * {
          font-family: "JetbrainsMono NF";
          font-size: 12px;
          min-height: 0;
          background: transparent
        }
        waybar {
           background: transparent;
           color: @text;
           margin: 5px 5px;
           margin-bottom: 0px;
         }
        #window {
          border-radius: 1rem;
        }
        
         #workspaces {
           border-radius: 1rem;
           margin: 5px;
           background-color: @surface0;
           margin-left: 1rem;
         }
        
         #workspaces button {
           color: @lavender;
           border-radius: 1rem;
           padding: 0.5rem;
         }
        
         #workspaces button.active {
           color: @sky;
           border-radius: 1rem;
         }
        
         #workspaces button:hover {
           color: @sapphire;
           border-radius: 1rem;
         }
        
         #window,
         #hyprland-window,
         #custom-music,
         #tray,
         #backlight,
         #clock,
         #battery,
         #pulseaudio,
         #custom-lock,
         #custom-power {
           background-color: @surface0;
           padding: 0.5rem 1rem;
           margin: 5px 0;
         }
        
         #clock {
           color: @blue;
           border-radius: 0px 1rem 1rem 0px;
           margin-right: 1rem;
         }
        
         #battery {
           color: @green;
         }
        
         #battery.charging {
           color: @green;
         }
        
         #battery.warning:not(.charging) {
           color: @red;
         }
        
         #backlight {
           color: @yellow;
         }
        
         #battery {
             border-radius: 0;
         }

         #backlight {
            border-radius: 1rem 0px 0px 1rem;
         }
        
         #pulseaudio {
           color: @maroon;
           border-radius: 1rem 0px 0px 1rem;
           margin-left: 1rem;
         }
        
         #custom-music {
           color: @mauve;
           border-radius: 1rem;
         }
        
         #custom-lock {
             border-radius: 1rem 0px 0px 1rem;
             color: @lavender;
         }
        
         #custom-power {
             margin-right: 1rem;
             border-radius: 0px 1rem 1rem 0px;
             color: @red;
         }
        
         #tray {
           margin-right: 1rem;
           border-radius: 1rem;
         }
      '';
    };
    hyprlock = {
      enable = true;
    };
  };
  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = "on";
      preload = [ "/wallpapers/wallpaper.png" ];
      wallpaper = ", /wallpapers/wallpaper.png";
    };
  };
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      source = [ "$HOME/.config/hypr/mocha.hypr.conf" ]; 
      monitor = ["eDP-1,1366x768@60,0x0,1" "DP-2,1920x1080@60,1366x0,1.3"];
      "$accent" = "$mauve";
    
      general = {
        border_size = 2;
        "col.inactive_border" = "$base";
        "col.active_border" = "$accent";
      };
      decoration = {
        rounding = 10;
        rounding_power = 2;

        shadow = {
          enabled = true;
          range = 4;
          render_power = 3;
          color = "rgba(1a1a1aee)";
        };
      };
      animation = {
        # enabled = true;
        bezier = [
          "easeOutQuint,   0.23, 1,    0.32, 1"
          "easeInOutCubic, 0.65, 0.05, 0.36, 1"
          "linear,         0,    0,    1,    1"
          "almostLinear,   0.5,  0.5,  0.75, 1"
          "quick,          0.15, 0,    0.1,  1"
        ];
        animation = [
          "global,        1,     10,    default"
          "border,        1,     5.39,  easeOutQuint"
          "windows,       1,     4.79,  easeOutQuint"
          "windowsIn,     1,     4.1,   easeOutQuint, popin 87%"
          "windowsOut,    1,     1.49,  linear,       popin 87%"
          "fadeIn,        1,     1.73,  almostLinear"
          "fadeOut,       1,     1.46,  almostLinear"
          "fade,          1,     3.03,  quick"
          "layers,        1,     3.81,  easeOutQuint"
          "layersIn,      1,     4,     easeOutQuint, fade"
          "layersOut,     1,     1.5,   linear,       fade"
          "fadeLayersIn,  1,     1.79,  almostLinear"
          "fadeLayersOut, 1,     1.39,  almostLinear"
          "workspaces,    1,     1.94,  almostLinear, fade"
          "workspacesIn,  1,     1.21,  almostLinear, fade"
          "workspacesOut, 1,     1.94,  almostLinear, fade"
          "zoomFactor,    1,     7,     quick"
        ];
      };
      input = {
        kb_layout = "gb";
        touchpad = {
          disable_while_typing = false;
          natural_scroll = true;
        };
      };
      gesture = [
        "3, horizontal, workspace"
      ];
      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };
      

      "$mainMod" = "SUPER";
      "$terminal" = "ghostty";
      "$fileManager" = "dolphin";
      "$menu" = "fuzzel";
      
      bind = [
        "$mainMod, Return, exec, $terminal"
        "$mainMod, Q, killactive,"
        "$mainMod_SHIFT, M, exit,"
        "$mainMod, E, exec, $fileManager"
        "$mainMod, D, exec, $menu"
        "$mainMod, P, pseudo,"
        "$mainMod, J, togglesplit,"
        "$mainMod, L, exec, hyprlock"

        "$mainMod, left, moveFocus, l"
        "$mainMod, right, moveFocus, r"
        "$mainMod, up, moveFocus, u"
        "$mainMod, down, moveFocus, d"

        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"
        "$mainMod, F1, workspace, 11"
        "$mainMod, F2, workspace, 12"
        "$mainMod, F3, workspace, 13"
        "$mainMod, F4, workspace, 14"
        "$mainMod, F5, workspace, 15"
        "$mainMod, F6, workspace, 16"
        "$mainMod, F7, workspace, 17"
        "$mainMod, F8, workspace, 18"
        "$mainMod, F9, workspace, 19"
        "$mainMod, F10, workspace, 20"

        "$mainMod SHIFT, 1, movetoworkspace, 1"
        "$mainMod SHIFT, 2, movetoworkspace, 2"
        "$mainMod SHIFT, 3, movetoworkspace, 3"
        "$mainMod SHIFT, 4, movetoworkspace, 4"
        "$mainMod SHIFT, 5, movetoworkspace, 5"
        "$mainMod SHIFT, 6, movetoworkspace, 6"
        "$mainMod SHIFT, 7, movetoworkspace, 7"
        "$mainMod SHIFT, 8, movetoworkspace, 8"
        "$mainMod SHIFT, 9, movetoworkspace, 9"
        "$mainMod SHIFT, 0, movetoworkspace, 10"
        "$mainMod SHIFT, F1, movetoworkspace, 11"
        "$mainMod SHIFT, F2, movetoworkspace, 12"
        "$mainMod SHIFT, F3, movetoworkspace, 13"
        "$mainMod SHIFT, F4, movetoworkspace, 14"
        "$mainMod SHIFT, F5, movetoworkspace, 15"
        "$mainMod SHIFT, F6, movetoworkspace, 16"
        "$mainMod SHIFT, F7, movetoworkspace, 17"
        "$mainMod SHIFT, F8, movetoworkspace, 18"
        "$mainMod SHIFT, F9, movetoworkspace, 19"
        "$mainMod SHIFT, F10, movetoworkspace, 20"

        ", F14, exec, wtype \"🥺\""
        
        "$mainMod, mouse_down, workspace, e-1"
        "$mainMod, mouse_up, workspace, e+1"
      ];
      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];
      bindel = [
        ",XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ",XF86AudioPlay, exec, playerctl play-pause"
        ",XF86MonBrightnessUp, exec, brightnessctl -e4 -n2 set 5%+"
        ",XF86MonBrightnessDown, exec, brightnessctl -e4 -n2 set 5%-"
        ",XF86Tools, exec, /home/ecorous/scripts/brightness_toggle.nu"
        ",XF86Search, exec, /home/ecorous/scripts/brightness_set_1.sh"
      ];
      bindl = [
        ", switch:Lid Switch, exec, hyprlock"
      ];

      exec-once = [
        "kwalletd &"
        "ghostty & mako & waybar & hyprpaper"
        "bash -c \"sleep 5; nm-applet &\" &"
      ];
    };
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
  home.file.".config/hypr/mocha.hypr.conf".source = ../files/mocha.hypr.conf;
  home.file.".config/waybar/mocha.css".source = ../files/mocha.waybar.css;
}
