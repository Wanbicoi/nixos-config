{ inputs, pkgs, ... }:
{
  imports = [ inputs.silentSDDM.nixosModules.default ];

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = false; # X11 greeter is more reliable for mouse input at login
    package = pkgs.kdePackages.sddm;
  };

  programs.silentSDDM = {
    enable = true;
    theme = "default";
  };
}
