{ ... }:
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

    # TODO: Remove this later when finished setup hyprland
    displayManager.sddm.enable = true;
    displayManager.sddm.wayland.enable = true;
    # displayManager.defaultSession = "plasma";
    # desktopManager.plasma6.enable = true;
  };
}
