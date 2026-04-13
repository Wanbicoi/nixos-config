{ ... }:
{
  home.sessionVariables = {
    NIXOS_OZONE_WL = "1"; # Tells Electron apps (VS Code, Discord) to use Wayland
    MOZ_ENABLE_WAYLAND = "1"; # Tells Firefox to use Wayland

    # Input method environment variables for ibus.
    # GTK_IM_MODULE = "ibus";
    # QT_IM_MODULE = "ibus";
    # SDL_IM_MODULE = "ibus";
    # XMODIFIERS = "@im=ibus";
    XMODIFIERS = "@im=fcitx";
    QT_IM_MODULE = "fcitx"; # Fallback for Qt5
    QT_IM_MODULES = "wayland;fcitx"; # Strategy for Qt 6.10.2+

    DOCKER_HOST = "unix://$XDG_RUNTIME_DIR/docker.sock"; # For rootless Docker
  };
}
