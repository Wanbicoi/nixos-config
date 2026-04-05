{ ... }:
{
  wayland.windowManager.hyprland.settings.exec-once = [
    # "hash dbus-update-activation-environment 2>/dev/null"
    # "dbus-update-activation-environment --all --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
    # "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"

    # "hyprlock"

    # Start core session tray/background apps.
    # NetworkManager tray icon.
    # "nm-applet &"
    # Power/battery alert daemon.
    # "poweralertd &"
    # Keep clipboard contents persistent across app exits.
    "wl-clip-persist --clipboard both &"
    # Store clipboard changes into cliphist.
    "wl-paste --watch cliphist store &"
    # Launch commonly used apps at session start.
    "firefox &"
    "code &"
    # Top status bar.
    # "waybar &"
    # Caelestia is started by its systemd user service.
    # "caelestia shell -d &"
    # Notification daemon and control center. 
    # "swaync &"
    # Auto-mount removable drives with tray notifications.
    "udiskie --automount --notify --smart-tray &"
    # Set cursor theme and size for the session.
    # "hyprctl setcursor Bibata-Modern-Ice 24 &"
    # Initialize wallpaper script.
    # "init-wallpaper &"
    # "awww-daemon &"
    # "awww img -t none ~/nixos-config/wallpapers/space.png"
  ];
}
