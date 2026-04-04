{ username, ... }:
{
  services = {
    xserver = {
      enable = true;
      # Default to us
      # xkb.layout = "us";
    };

    # TODO: Research for this later
    # displayManager.autoLogin = {
    #   enable = true;
    #   user = "${username}";
    # };

    # TODO: Research for this later, seems like it is touchpad settings at system level
    # libinput = {
    #   enable = true;
    # };
  };
  # TODO: Research for this later
  # To prevent getting stuck at shutdown
  # systemd.settings.Manager.DefaultTimeoutStopSec = "10s";
}
