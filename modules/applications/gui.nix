{ pkgs, ... }:
{
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "x-scheme-handler/http" = [ "firefox.desktop" ];
      "x-scheme-handler/https" = [ "firefox.desktop" ];
      "x-scheme-handler/obsidian" = [ "obsidian.desktop" ];
      "text/html" = [ "firefox.desktop" ];
      "application/xhtml+xml" = [ "firefox.desktop" ];
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

    obsidian
    vscode

    anki
    
    # TODO: remove later
    gpclient
  ];
}
