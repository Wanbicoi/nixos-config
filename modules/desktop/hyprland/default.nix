{ ... }:
{
  imports = [
    ./../../applications
    ./hyprland.nix
    ./exec-once.nix
    ./monitors.nix
    ./settings.nix
    ./binds.nix
    ./windowrules.nix
    ./gui
    ./desktop/caelestia
    # ./waybar
    # ./noctalia.nix
    # ./hyprlock.nix
    # ./variables.nix
    ./env-vars.nix
  ];
}
