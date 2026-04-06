{ ... }:
{
  home.sessionVariables = {
    NIXOS_OZONE_WL = "1"; # Tells Electron apps (VS Code, Discord) to use Wayland
    MOZ_ENABLE_WAYLAND = "1"; # Tells Firefox to use Wayland
  };
}
