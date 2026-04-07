{ pkgs, ... }:
{
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = false; # X11 greeter is more reliable for mouse input at login
    package = pkgs.kdePackages.sddm;
    theme = "catppuccin-mocha-mauve";
  };
  environment.systemPackages = [
    (pkgs.catppuccin-sddm.override {
      flavor = "mocha";
      accent = "mauve";
      font = "Noto Sans";
      fontSize = "9";
      # loginBackground = true;
    })
  ];
}
