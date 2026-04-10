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
    settings = {
      # bar.status = {
      #   showBattery = false;
      # };
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
            "dolphin"
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
          showLockStatus = false;
        };
      };
      border = {
        rounding = 8;
        thickness = 0;
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
