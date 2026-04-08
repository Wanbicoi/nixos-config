{ ... }:
{
  services.wlsunset = {
    enable = true;
    # latitude = "10.8"; # Ho Chi Minh City coordinates
    # longitude = "106.6";
    temperature = {
      day = 6500;
      night = 4500;
    };
    sunrise = "06:00";
    sunset = "20:30";
  };
}
