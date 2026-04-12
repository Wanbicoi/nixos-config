{
  lib,
  pkgs,
  ...
}:
let
  gtk-theme-name = "Orchis-Light-Compact";
  gtk-theme = pkgs.orchis-theme.override {
    border-radius = 8;
    tweaks = [
      "compact"
      "macos"
    ];
  };
  icon-theme-name = "Papirus-Light";
in
{
  gtk = {
    enable = true;
    font = {
      name = "Maple Mono";
      # size = if (host == "p14s") then 14 else 12;
    };
    theme = {
      name = gtk-theme-name;
      package = gtk-theme;
    };
    iconTheme = {
      name = icon-theme-name;
      package = pkgs.papirus-icon-theme.override { color = "blue"; };
    };
    cursorTheme = {
      name = "Bibata-Modern-Ice";
      package = pkgs.bibata-cursors;
      size = 24;
    };

    gtk3 = {
      extraConfig = {
        gtk-application-prefer-dark-theme = lib.mkForce false;
      };
    };

    gtk4 = {
      theme = {
        name = gtk-theme-name;
        package = gtk-theme;
      };
      extraConfig = {
        gtk-application-prefer-dark-theme = lib.mkForce false;
      };
    };
  };
  dconf.enable = true;
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      gtk-theme = gtk-theme-name;
      icon-theme = icon-theme-name;
      color-scheme = "default";
    };
  };

  home.pointerCursor = {
    name = "Bibata-Modern-Ice";
    package = pkgs.bibata-cursors;
    size = 20;
  };
}
