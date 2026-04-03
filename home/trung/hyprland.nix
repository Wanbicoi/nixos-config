{ pkgs, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = ''
      source = ${pkgs.hyprland}/share/hypr/hyprland.conf
      source = ~/.config/hypr/monitors.conf
    '';
  };

  home.packages = with pkgs; [
    waybar
    kitty
    wofi
    nwg-displays
  ];
}