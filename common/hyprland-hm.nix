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
          modules-center = [ "hyprland/window" ];
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
    hyprlock = {
      enable = true;
      settings = {
        source = [ "$HOME/.config/hypr/mocha.hypr.conf" ];
        "$accent" = "$mauve";
        "$accentAlpha" = "$mauveAlpha";
        "$font" = "JetBrainsMono Nerd Font";

        general = {
          hide_cursor = false;
        };

        background = {
          monitor = "";
          color = "$base";
        };

        label = [
          {
            monitor = "";
            text = "Layout: $LAYOUT";
            color = "$text";
            font_size = 25;
            font_family = "$font";
            position = "30, -30";
            halign = "left";
            valign = "top";
          }
          {
            monitor = "";
            text = "$TIME";
            color = "$text";
            font_size = 90;
            font_family = "$font";
            position = "-30, 0";
            halign = "right";
            valign = "top";
          }
          {
            monitor = "";
            text = "cmd[update:43200000] date +\"%A, %d %B %Y\"";
            color = "$text";
            font_size = 25;
            font_family = "$font";
            position = "-30, -150";
            halign = "right";
            valign = "top";
          }
        ];
        image = [
          {
            monitor = "";
            path = "$HOME/.face";
            size = 100;
            border_color = "$accent";
            position = "0, 75";
            halign = "center";
            valign = "center";
          }
        ];
        input-field = {
          monitor = "";
          size = "300, 60";
          outline_thickness = 4;
          dots_size = 0.2;
          dots_spacing = 0.2;
          dots_center = true;
          outer_color = "$accent";
          inner_color = "$surface0";
          font_color = "$text";
          fade_on_empty = false;
          placeholder_text = "<span foreground=\"##$textAlpha\"><i> Logged in as </i><span foreground=\"##$accentAlpha\">$USER</span></span>";
          hide_input = false;
          check_color = "$accent";
          fail_color = "$red";
          fail_text = "<i>$FAIL <b>($ATTEMPTS)</b></i>";
          capslock_color = "$yellow";
          position = "0, -47";
          halign = "center";
          valign = "cetner";
        };     
      };
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
      monitor = "eDP-1,1366x768@60,0x0,1";
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
      gestures = {
        workspace_swipe = true;
      };
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

        "$mainMod, mouse_down, workspace, e+1"
        "$mainMod, mouse_up, workspace, e-1"
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
        ",XF86MonBrightnessUp, exec, brightnessctl -e4 -n2 set 5%+"
        ",XF86MonBrightnessDown, exec, brightnessctl -e4 -n2 set 5%-"
        ",XF86Tools, exec, /home/ecorous/scripts/brightness_toggle.nu"
        ",XF86Search, exec, /home/ecorous/scripts/brightness_set_1.sh"
      ];

      exec-once = [
        "kwalletd &"
        "ghostty & mako & waybar & hyprpaper"
        "nm-applet &"
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
}
