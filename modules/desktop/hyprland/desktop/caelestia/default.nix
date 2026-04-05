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
    };
    cli = {
      enable = true; # Also add caelestia-cli to path
      settings = {
        theme.enableGtk = false;
      };
    };
  };
}
