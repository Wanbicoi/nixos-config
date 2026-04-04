{ pkgs, ... }:
{
  home.packages = with pkgs; [
    ## Multimedia
    # amberol # music player
    # audacity
    # gimp
    # obs-studio
    # media-downloader
    pavucontrol
    
    networkmanagerapplet
    # nm-connection-editor

    ## Office
    libreoffice
    gnome-calculator

    # Browsers
    firefox
    microsoft-edge

    obsidian
    vscode
  ];
}
