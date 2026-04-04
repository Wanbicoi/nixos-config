{ pkgs, ... }:

{
  imports = [
    ./hyprland.nix
    ./dev.nix
  ];

  home.username = "trung";
  home.homeDirectory = "/home/trung";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  programs.git.enable = true;
  programs.git.settings.user.name = "Trung Hoang";
  programs.git.settings.user.email = "wanbicoi123@gmail.com";
  programs.neovim.enable = true;

  home.packages = with pkgs; [
    vscode
    firefox
    nil
    nixpkgs-fmt
    xfce.thunar
    xfce.thunar-volman
    nixfmt
    ventoy
  ];
}