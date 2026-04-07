{ pkgs, ... }:
{
  imports = [
    ../gtk.nix
  ];
  # TODO: Move to custom
  home.packages = with pkgs; [
    wofi
    awww # Animated wallpaper daemon for Wayland
    grimblast # Screenshot helper script for Hyprland/Sway workflows
    hyprpicker # Color picker for Wayland compositors
    grim # Capture screenshots on Wayland
    slurp # Select a screen region (used by screenshot tools)
    wl-clip-persist # Keep clipboard content after source app exits

    cliphist # Clipboard history manager for wl-clipboard
    wl-clipboard

    poweralertd # Power management alert daemon for battery status notifications
    swaynotificationcenter # Notification center for Wayland (inspired by mako)

    wf-recorder # Screen recorder for Wayland sessions
    # glib # Core GNOME utility library used by many desktop apps
    wayland # Wayland client and protocol libraries/tools
    direnv # Auto-load environment variables per project directory
    tesseract # OCR engine to extract text from images/screenshots
  ];
  # TODO: Research for this later
  # systemd.user.targets.hyprland-session.Unit.Wants = [
  #   "xdg-desktop-autostart.target"
  # ];

  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;

    xwayland = {
      enable = true;
      # hidpi = true;
    };
    # enableNvidiaPatches = false;
    systemd.enable = true;
  };
}
