{ pkgs, ... }:
{
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "x-scheme-handler/http" = [ "google-chrome.desktop" ];
      "x-scheme-handler/https" = [ "google-chrome.desktop" ];
      "x-scheme-handler/obsidian" = [ "obsidian.desktop" ];
      "text/html" = [ "google-chrome.desktop" ];
      "application/xhtml+xml" = [ "google-chrome.desktop" ];
    };
  };

  home.packages = with pkgs; [
    ## Multimedia
    # amberol # music player
    # audacity
    # gimp
    # obs-studio
    # media-downloader
    pavucontrol

    # networkmanagerapplet
    # nm-connection-editor
    mousepad

    ## Office
    libreoffice
    # gnome-calculator

    #
    keepassxc

    # Browsers
    firefox
    microsoft-edge
    google-chrome
    brave

    obsidian
    vscode

    anki
    
    # TODO: remove later
    gpclient
  ];
}
