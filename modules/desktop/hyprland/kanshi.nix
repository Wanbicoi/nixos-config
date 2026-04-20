{ ... }:
{
  services.kanshi = {
    enable = true;
    systemdTarget = "hyprland-session.target";
    profiles = {
      # Profile 1: Only the laptop is present
      mobile = {
        outputs = [
          {
            criteria = "eDP-1"; # Your laptop screen name
            status = "enable";
          }
        ];
      };
      # Profile 2: External monitor is plugged in
      docked = {
        outputs = [
          {
            criteria = "eDP-1";
            status = "disable"; # This turns off the laptop screen
          }
          {
            criteria = "HDMI-A-1"; # Replace with your external monitor name
            mode = "1920x1080@60Hz";
            position = "0,0";
          }
        ];
      };
    };
  };
}
