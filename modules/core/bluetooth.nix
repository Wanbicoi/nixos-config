{ ... }:
{
  hardware.bluetooth = {
    enable = true;
    # TODO: Research for this later
    powerOnBoot = false;
  };

  services.blueman.enable = true;
}
