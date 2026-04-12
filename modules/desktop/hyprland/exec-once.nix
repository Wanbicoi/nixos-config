{ ... }:
{
  wayland.windowManager.hyprland.settings.exec-once = [
    "fcitx5 &"
    # "ibus-daemon --daemonize --replace --xim &"
    # "hash dbus-update-activation-environment 2>/dev/null"
    # "dbus-update-activation-environment --all --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
    # "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"

    # Start core session tray/background apps.
    # NetworkManager tray icon.
    # "nm-applet &"
    # Power/battery alert daemon.
    # "poweralertd &"
    # Keep clipboard contents persistent across app exits.
    # TODO: make this modular
    "wl-clip-persist --clipboard both &"
    "wl-paste --type text --watch cliphist store &"
    "wl-paste --type image --watch cliphist store &"
    # "udiskie --automount --notify --smart-tray &"
    
    # Launch commonly used apps at session start.
    "firefox &"
    "code &"
    # Set cursor theme and size for the session.
    "hyprctl setcursor oreo-cursors-plus 20 &"
  ];
}
