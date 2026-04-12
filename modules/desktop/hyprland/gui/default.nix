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

    # udiskie # Auto-mount removable media
    # awww
  ];

  # gtk = {
  #   enable = true;
  #   gtk4.theme = null;
  #   cursorTheme = {
  #     name = "Bibata-Modern-Ice";
  #     package = pkgs.bibata-cursors;
  #     size = 24;
  #   };
  #   theme = {
  #     name = "Orchis-Blue-Light-Compact";
  #     package = pkgs.orchis-theme.override {
  #       # Look at the 'tweaks' list in the source code you provided:
  #       # Options: "solid" "compact" "black" "primary" "macos" "submenu" "nord" "dracula"
  #       tweaks = [
  #         "black"
  #         "compact"
  #         "primary"
  #       ];
  #       border-radius = 8;
  #     };
  #   };
  #   iconTheme = {
  #     # The name string for the standard version is usually "WhiteSur" or "WhiteSur-dark"
  #     name = "WhiteSur";

  #     package = pkgs.whitesur-icon-theme.override {
  #       # Options: "default", "purple", "pink", "red", "orange", "yellow", "green", "grey", "nord", "all"
  #       themeVariants = [ "default" ];
  #       boldPanelIcons = true;
  #     };
  #   };
  # };

  # home.pointerCursor = {
  #   name = "Bibata-Modern-Ice";
  #   package = pkgs.bibata-cursors;
  #   size = 20;
  # };
}
