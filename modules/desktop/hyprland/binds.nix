{ ... }:
{
  wayland.windowManager.hyprland.settings = {
    "$mod" = "SUPER";
    "$terminal" = "kitty";
    "$fileManager" = "nemo";

    # Hyprland bind behavior tuning.
    binds = {
      scroll_event_delay = 100;
      movefocus_cycles_fullscreen = true;
    };

    bind = [
      # Standard press-only keybinds.
      "$mod, T, exec, $terminal"
      "$mod, W, killactive,"
      "$mod, M, exec, command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch exit"
      "$mod, E, exec, $fileManager"
      "$mod, F, togglefloating,"
      "$mod, P, pseudo, # dwindle"
      "$mod, J, layoutmsg, togglesplit # dwindle"
      # Open a readable preview window with active metadata (class/title/etc.) for window rules.
      "$mod, I, exec, sh -c 'tmp=$(mktemp --suffix=.txt); hyprctl activewindow > \"$tmp\"; mousepad \"$tmp\"; rm -f \"$tmp\"'"

      # Move focus with mainMod + arrow keys
      "$mod, left, movefocus, l"
      "$mod, right, movefocus, r"
      "$mod, up, movefocus, u"
      "$mod, down, movefocus, d"

      # Switch workspaces with mainMod + [0-9]
      "$mod, 1, workspace, 1"
      "$mod, 2, workspace, 2"
      "$mod, 3, workspace, 3"
      "$mod, 4, workspace, 4"
      "$mod, 5, workspace, 5"
      "$mod, 6, workspace, 6"
      "$mod, 7, workspace, 7"
      "$mod, 8, workspace, 8"
      "$mod, 9, workspace, 9"
      "$mod, 0, workspace, 10"

      # Move active window to a workspace with mainMod + SHIFT + [0-9]
      "$mod SHIFT, 1, movetoworkspace, 1"
      "$mod SHIFT, 2, movetoworkspace, 2"
      "$mod SHIFT, 3, movetoworkspace, 3"
      "$mod SHIFT, 4, movetoworkspace, 4"
      "$mod SHIFT, 5, movetoworkspace, 5"
      "$mod SHIFT, 6, movetoworkspace, 6"
      "$mod SHIFT, 7, movetoworkspace, 7"
      "$mod SHIFT, 8, movetoworkspace, 8"
      "$mod SHIFT, 9, movetoworkspace, 9"
      "$mod SHIFT, 0, movetoworkspace, 10"

      # wf-recorder toggles: fullscreen, region, and fullscreen with audio.
      # "$mod SHIFT, R, exec, sh -c 'if pgrep -x wf-recorder >/dev/null; then pkill -INT -x wf-recorder && hyprctl notify 1 2000 \"rgb(8ec07c)\" \"wf-recorder stopped\"; else mkdir -p \"$HOME/Videos/Recordings\"; hyprctl notify 1 2000 \"rgb(83a598)\" \"wf-recorder fullscreen\"; wf-recorder -f \"$HOME/Videos/Recordings/wf-$(date +%Y-%m-%d_%H-%M-%S).mp4\"; fi'"
      # "$mod SHIFT, G, exec, sh -c 'if pgrep -x wf-recorder >/dev/null; then pkill -INT -x wf-recorder && hyprctl notify 1 2000 \"rgb(8ec07c)\" \"wf-recorder stopped\"; else mkdir -p \"$HOME/Videos/Recordings\"; geom=$(slurp) || exit 0; hyprctl notify 1 2000 \"rgb(fabd2f)\" \"wf-recorder region\"; wf-recorder -g \"$geom\" -f \"$HOME/Videos/Recordings/wf-region-$(date +%Y-%m-%d_%H-%M-%S).mp4\"; fi'"
      # "$mod SHIFT, A, exec, sh -c 'if pgrep -x wf-recorder >/dev/null; then pkill -INT -x wf-recorder && hyprctl notify 1 2000 \"rgb(8ec07c)\" \"wf-recorder stopped\"; else mkdir -p \"$HOME/Videos/Recordings\"; hyprctl notify 1 2000 \"rgb(d3869b)\" \"wf-recorder with audio\"; wf-recorder -a -f \"$HOME/Videos/Recordings/wf-audio-$(date +%Y-%m-%d_%H-%M-%S).mp4\"; fi'"

      # Example special workspace (scratchpad)
      # "$mod, S, togglespecialworkspace, magic"
      # "$mod SHIFT, S, movetoworkspace, special:magic"

      # Scroll through existing workspaces with mainMod + scroll
      "$mod, mouse_down, workspace, e+1"
      "$mod, mouse_up, workspace, e-1"

      # Volume keys on press; brightness and media are handled in the Caelestia module.
      ",XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
      ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
      ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
    ];

    bindm = [
      # Mouse drag binds.
      "$mod, mouse:272, movewindow"
      "$mod, mouse:273, resizewindow"
    ];

    bindel = [
      # Repeatable volume controls while held.
      ",XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
      ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
      ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
    ];

    # No release-only bindings in the general Hyprland layer right now.
    bindl = [ ];
  };
}
