{ ... }:
{
  programs.waybar = {
    enable = true;
  };
  imports = [
    ./settings.nix
    ./style.nix
  ];
}
