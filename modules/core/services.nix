{ pkgs, ... }:
{
  services = {
    gvfs.enable = true;

    gnome = {
      tinysparql.enable = true;
      gnome-keyring.enable = true;
    };

    dbus.enable = true;
    fstrim.enable = true;
    fwupd.enable = true;

    # NOTE: for https://docs.noctalia.dev/getting-started/nixos/
    power-profiles-daemon.enable = true;
    upower.enable = true;

    # needed for GNOME services outside of GNOME Desktop
    # dbus.packages = with pkgs; [
    #   gcr
    #   gnome-settings-daemon
    # ];

    # logind.settings.Login = {
    #   # don’t shutdown when power button is short-pressed
    #   HandlePowerKey = "ignore";

    #   # ignore lid close when docked/external monitor conected
    #   HandleLidSwitchDocked = "ignore";
    # };

    udisks2.enable = true;

    greetd = {
      enable = true;
      settings.default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-user-session --cmd start-hyprland";
        user = "trung";
      };
    };

    # this is a life saver.
    # literally no documentation about this anywhere.
    # might be good to write about this...
    # https://www.reddit.com/r/NixOS/comments/u0cdpi/tuigreet_with_xmonad_how/
    systemd.services.greetd.serviceConfig = {
      Type = "idle";
      StandardInput = "tty";
      StandardOutput = "tty";
      StandardError = "journal"; # Without this errors will spam on screen
      # Without these bootlogs will spam on screen
      TTYReset = true;
      TTYVHangup = true;
      TTYVTDisallocate = true;
    };
  };
}
