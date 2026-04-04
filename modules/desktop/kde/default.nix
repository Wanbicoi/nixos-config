{ pkgs, ... }:

{
  programs.git.enable = true;
  programs.git.settings.user.name = "Trung Hoang";
  programs.git.settings.user.email = "wanbicoi123@gmail.com";
  programs.neovim.enable = true;

  home.packages = with pkgs; [
    vscode
    firefox
    thunar
    thunar-volman
  ];
}