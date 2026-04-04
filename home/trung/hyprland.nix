{ pkgs, ... }:

{
  gtk = {
    enable = true;
    theme = {
      name = "Adwaita";
      package = pkgs.gnome-themes-extra;
    };
    iconTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };
    cursorTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      exec-once = [
        "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE HYPRLAND_INSTANCE_SIGNATURE"
        "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE HYPRLAND_INSTANCE_SIGNATURE"
      ];
    };
    extraConfig = ''
      source = ${pkgs.hyprland}/share/hypr/hyprland.conf
      source = ~/.config/hypr/monitors.conf
    '';
  };

  programs.waybar = {
    enable = false;
    systemd.enable = false;
    settings = [
      {
        layer = "top";
        position = "top";
        height = 34;
        modules-left = [ "hyprland/workspaces" ];
        modules-center = [ "clock" ];
        modules-right = [ "network" "pulseaudio" "battery" "tray" ];

        clock = {
          format = "{:%a %d %b  %H:%M}";
          tooltip-format = "{:%Y-%m-%d %H:%M:%S}";
        };

        network = {
          format-wifi = "WiFi {signalStrength}%";
          format-ethernet = "LAN";
          format-disconnected = "Offline";
          tooltip-format = "{ifname} {ipaddr}";
        };

        pulseaudio = {
          format = "Vol {volume}%";
          format-muted = "Muted";
          on-click = "pavucontrol";
        };

        battery = {
          format = "Bat {capacity}%";
          format-charging = "Charging {capacity}%";
          format-plugged = "Plugged";
          states = {
            warning = 30;
            critical = 15;
          };
        };

        tray = {
          spacing = 8;
        };
      }
    ];

    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font", "Noto Sans", sans-serif;
        font-size: 13px;
        min-height: 0;
      }

      window#waybar {
        background: #f5f7fa;
        color: #1f2937;
        border-bottom: 1px solid #d8dee9;
      }

      #workspaces button,
      #clock,
      #network,
      #pulseaudio,
      #battery,
      #tray {
        background: #e9edf3;
        color: #1f2937;
        margin: 6px 4px;
        padding: 4px 10px;
        border-radius: 10px;
      }

      #workspaces button.active {
        background: #bfdbfe;
        color: #1e3a8a;
      }

      #workspaces button:hover {
        background: #dbeafe;
      }

      #battery.warning {
        color: #9a3412;
      }

      #battery.critical {
        color: #b91c1c;
      }
    '';
  };

  xdg.configFile."wofi/config".text = ''
    width=32%
    height=42%
    location=center
    show=drun
    prompt=Search
    allow_markup=true
    no_actions=true
    normal_window=true
    term=kitty
  '';

  xdg.configFile."wofi/style.css".text = ''
    * {
      font-family: "JetBrainsMono Nerd Font", "Noto Sans", sans-serif;
      font-size: 14px;
    }

    window {
      margin: 0;
      border: 1px solid #d8dee9;
      border-radius: 14px;
      background-color: #f9fafb;
      color: #1f2937;
    }

    #input {
      margin: 12px;
      padding: 10px 12px;
      border: 1px solid #cbd5e1;
      border-radius: 10px;
      background-color: #ffffff;
      color: #111827;
    }

    #inner-box {
      margin: 0 12px 12px 12px;
      background: transparent;
    }

    #entry {
      padding: 8px 10px;
      border-radius: 10px;
      color: #1f2937;
    }

    #entry:selected {
      background-color: #dbeafe;
      color: #1e3a8a;
    }
  '';

  home.packages = with pkgs; [
    # waybar
    kitty
    wofi
    nwg-displays
    copyq
    pavucontrol
    adwaita-icon-theme
    gnome-themes-extra
  ];
}