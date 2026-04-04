{ pkgs, ... }:
{
  home.sessionVariables = {
    NIXOS_OZONE_WL = "1"; # Tells Electron apps (VS Code, Discord) to use Wayland
  };
}
