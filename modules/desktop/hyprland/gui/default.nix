{ pkgs, ... }:
{
  home.packages = with pkgs; [
    ## Auth and storage
    polkit_gnome # Polkit authentication dialog for privileged actions
    gnome-disk-utility # GUI disk utility (mount/format/SMART)

    mission-center # GUI resource monitor

    ## Office
    networkmanagerapplet
    # nm-connection-editor # Not available in nixpkgs, networkmanagerapplet provides GUI access

    udiskie # Auto-mount removable media
    awww

    nemo # File manager
  ];

  gtk = {
    enable = true;
    gtk4.theme = null;
    cursorTheme = {
      name = "Bibata-Modern-Ice";
      package = pkgs.bibata-cursors;
      size = 24;
    };
  };

  home.pointerCursor = {
    name = "Bibata-Modern-Ice";
    package = pkgs.bibata-cursors;
    size = 24;
  };
}
