{ ... }:
{
  security = {
    rtkit.enable = true;
    sudo.enable = true;

    pam.services = {
      swaylock = { };
      # hyprlock = {
      #   fprintAuth = true;
      # };
    };
  };

  services.fprintd.enable = true;
}
