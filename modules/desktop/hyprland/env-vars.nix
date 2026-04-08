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
  };
}
