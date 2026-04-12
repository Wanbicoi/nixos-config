{ pkgs, ... }:
{
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "x-scheme-handler/http" = [ "microsoft-edge.desktop" ];
      "x-scheme-handler/https" = [ "microsoft-edge.desktop" ];
      "x-scheme-handler/obsidian" = [ "obsidian.desktop" ];
      "text/html" = [ "microsoft-edge.desktop" ];
      "application/xhtml+xml" = [ "microsoft-edge.desktop" ];
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

    obsidian
    vscode

    anki
    
    # TODO: remove later
    gpclient
  ];
}
