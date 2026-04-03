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
  programs.git.userName = "Trung Hoang";
  programs.git.userEmail = "wanbicoi123@gmail.com";
  programs.neovim.enable = true;

  home.packages = with pkgs; [
    vscode
    firefox
    nil
    nixpkgs-fmt
    xfce.thunar
  ];
}