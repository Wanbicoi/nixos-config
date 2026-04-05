{ ... }:
{
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true; # Enable when login to laptop
  };

  services.blueman.enable = true;
}
