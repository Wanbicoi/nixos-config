{ pkgs, ... }:
{
  imports = [
    ../gtk.nix
  ];
  # TODO: Move to custom
  home.packages = with pkgs; [
    # wofi
    # awww # Animated wallpaper daemon for Wayland
    # NOTE: No need these since the caelestia already has it
    # grimblast # Screenshot helper script for Hyprland/Sway workflows
    # hyprpicker # Color picker for Wayland compositors
    # grim # Capture screenshots on Wayland
    # TODO: make this modular 
    wl-clip-persist # Keep clipboard content after source app exits
    cliphist # Clipboard history manager for wl-clipboard
    wl-clipboard
    
    # TODO: consider kooha # GUI for wf-recorder to simplify screen recording on Wayland
    # slurp # Select a screen region (used by screenshot/video tools)
    # wf-recorder # Screen recorder for Wayland sessions

    # poweralertd # Power management alert daemon for battery status notifications
    # swaynotificationcenter # Notification center for Wayland (inspired by mako)

    # glib # Core GNOME utility library used by many desktop apps
    wayland # Wayland client and protocol libraries/tools
    # direnv # Auto-load environment variables per project directory
    # tesseract # OCR engine to extract text from images/screenshots
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
