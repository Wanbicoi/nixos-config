{ ... }:
{
  wayland.windowManager.hyprland.settings = {
    windowrule = [
      "match:class ^(imv)$, float on"
      "match:class ^(mpv)$, float on"
      "match:class ^(zenity)$, float on"
      "match:class ^(waypaper)$, float on"
      "match:class ^(SoundWireServer)$, float on"
      "match:class ^(.sameboy-wrapped)$, float on"
      "match:class ^(org.gnome.Calculator)$, float on"
      "match:class ^(org.gnome.FileRoller)$, float on"
      "match:class ^(org.pulseaudio.pavucontrol)$, float on"
      "match:class ^(org.xfce.mousepad)$, float on"
      "match:class ^(org.xfce.mousepad)$, center on"

      "match:class ^(rofi)$, pin on"
      "match:class ^(waypaper)$, pin on"

      "match:class ^(Aseprite)$, tile on"

      "match:class ^(zenity)$, size 850 500"
      "match:class ^(SoundWireServer)$, size 725 330"

      "match:title ^(Volume Control)$, size 700 450"
      "match:title ^(Volume Control)$, move 40 55%"

      "match:class ^(xdg-desktop-portal-gtk)$, dim_around on"
      "match:class ^(xdg-desktop-portal-gtk)$, float on"
      "match:class ^(xdg-desktop-portal-gtk)$, size 1000 700"

      "match:title ^(Picture-in-Picture)$, pin on"
      "match:title ^(Picture-in-Picture)$, float on"

      "match:class ^(firefox)$, workspace 1"
      "match:class ^(edge)$, workspace 1"
      "match:class ^(code)$, workspace 2"
      "match:class ^(Alacritty)$, workspace 3"
      "match:class ^(obsidian)$, workspace 4"
      "match:class ^(Aseprite)$, workspace 4"
      "match:class ^(Audacious)$, workspace 5"
      "match:class ^(Spotify)$, workspace 5"
      "match:class ^(com.obsproject.Studio)$, workspace 8"
      "match:class ^(discord)$, workspace 10"
      "match:class ^(WebCord)$, workspace 10"
      "match:class ^(vesktop)$, workspace 10"

      "match:class ^(mpv)$, idle_inhibit focus"
      "match:class ^(zen-beta)$, match:title ^(.*YouTube.*)$, idle_inhibit focus"
      "match:class ^(zen)$, idle_inhibit fullscreen"

      "match:xwayland true, rounding 0"

      # No gaps when only
      # "border_size 0, match:float 0, match:workspace w[tv1]"
      # "rounding 0, match:float 0, match:workspace w[tv1]"
      "border_size 0, match:float 0, match:workspace f[1]"
      "rounding 0, match:float 0, match:workspace f[1]"
    ];

    layerrule = [
      "match:namespace rofi, dim_around on"
      "match:namespace swaync-control-center, dim_around on"
    ];

    # No gaps when only
    # workspace = [
    #   "w[tv1], gapsout:0, gapsin:0"
    #   "f[1], gapsout:0, gapsin:0"
    # ];
  };
}
