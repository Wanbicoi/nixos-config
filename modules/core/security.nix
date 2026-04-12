{ pkgs, ... }:
{
  security = {
    rtkit.enable = true;
    sudo.enable = true;

    pam.services = {
      swaylock = { };
      sudo.fprintAuth = true;
      login.fprintAuth = true;
      login.enableGnomeKeyring = true;
      login.unixAuth = true;
      sddm.enableGnomeKeyring = true;
      # hyprlock = {
      #   fprintAuth = true;
      # };
    };
  };

  # TODO: Modular this
  services.fprintd = {
    enable = true;
    tod = {
      enable = true;
      driver = pkgs.libfprint-2-tod1-goodix-550a;
    };
  };
}
