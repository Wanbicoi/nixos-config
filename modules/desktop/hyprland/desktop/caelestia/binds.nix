{ ... }:
{
  wayland.windowManager.hyprland = {
    extraConfig = ''
      bind = $mod, space, exec, ulauncher
      bind = $mod, S, global, caelestia:screenshotFreeze

      bindl = $mod SHIFT, L, global, caelestia:lock
      bindl = , XF86MonBrightnessUp, global, caelestia:brightnessUp
      bindl = , XF86MonBrightnessDown, global, caelestia:brightnessDown
      bindl = , XF86AudioPlay, global, caelestia:mediaToggle
      bindl = , XF86AudioPause, global, caelestia:mediaToggle
      bindl = , XF86AudioNext, global, caelestia:mediaNext
      bindl = , XF86AudioPrev, global, caelestia:mediaPrev
      bindl = , XF86AudioStop, global, caelestia:mediaStop
    '';

    settings = {
      exec-once = [
        "hyprctl dispatch submap global"
      ];
      bind = [
        # Caelestia special workspace toggles
        "$mod, F9, exec, caelestia toggle sysmon"
        "$mod, F10, exec, caelestia toggle music"
        "$mod, F11, exec, caelestia toggle communication"
        "$mod, F12, exec, caelestia toggle todo"

        # Clipboard and emoji pickers
        "$mod, Period, exec, caelestia emoji -p && sleep 0.1 && wtype -M ctrl v -m ctrl"
        "$mod, V, exec, caelestia clipboard && sleep 0.1 && wtype -M ctrl v -m ctrl"
      ];
      bindl = [
        ", Print, exec, caelestia screenshot"
      ];

      bindr = [
        "Ctrl+$mod+Shift, R, exec, qs -c caelestia kill"
        "Ctrl+$mod+Alt, R, exec, qs -c caelestia kill; sleep .1; caelestia shell -d"
      ];
    };
  };
}
