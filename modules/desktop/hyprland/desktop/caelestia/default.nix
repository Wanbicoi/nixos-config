{ inputs, ... }:
{
  imports = [
    inputs.caelestia-shell.homeManagerModules.default
    ./binds.nix
  ];
  programs.caelestia = {
    enable = true;
    systemd = {
      enable = true;
      target = "graphical-session.target";
      environment = [ ];
    };
    # Take a look to ./default_config.jsonc for default options
    settings = {
      # bar.status = {
      #   showBattery = false;
      # };
      # appearance.anim.durations.scale = 0;
      paths.wallpaperDir = "~/nixos-config/wallpapers";
      general.idle = {
        lockBeforeSleep = false;
        timeouts = [ ];
        apps = {
          terminal = [
            "alacritty"
          ];
          audio = [
            "pavucontrol"
          ];
          playback = [
            "mpv"
          ];
          explorer = [
            "thunar"
          ];
        };
      };
      bar = {
        activeWindow = {
          inverted = true;
        };
        status = {
          showAudio = true;
          showBattery = true;
          showBluetooth = true;
          showKbLayout = false;
          showMicrophone = true;
          showNetwork = true;
          showWifi = true;
          showLockStatus = true;
        };
      };
      session.commands.logout = [
        "hyprctl"
        "dispatch"
        "exit"
      ];
      # launcher.actions = [
      #   {
      #     name = "Logout";
      #     icon = "exit_to_app";
      #     description = "Log out of the current session";
      #     command = [
      #       "hyprctl"
      #       "dispatch"
      #       "exit"
      #     ];
      #     enabled = true;
      #     dangerous = true;
      #   }
      # ];
      border = {
        rounding = 8;
        thickness = 0;
      };
      utilities.toasts = {
        capsLockChanged = false;
        numLockChanged = false;
        kbLayoutChanged = false;
      };
    };
    cli = {
      enable = true; # Also add caelestia-cli to path
      settings = {
        theme.enableGtk = false;
      };
    };
  };
}
