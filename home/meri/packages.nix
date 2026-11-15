# Everyday user packages for `meri`.
#
# Plasma 6 already installs the KDE application set (Dolphin, Konsole, Kate,
# Okular, Gwenview, Ark, Spectacle, ...), so only the extras are listed here.
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Unfree; scoped by the predicate in hosts/meri-laptop/default.nix.
    google-chrome
    microsoft-edge
    wpsoffice

    # Qt frontend for the fcitx5 input method (Bamboo engine is enabled
    # system-wide); without it the only way to edit the IME config is a file.
    qt6Packages.fcitx5-configtool

    # Codec-complete media player; Plasma's default player is limited.
    vlc

    # Spell checking for Kate/Okular (WPS bundles its own).
    hunspell
    hunspellDicts.en_US
  ];

  # Two browsers ship with the machine, so pick one explicitly instead of
  # letting xdg-open guess. Only browser roles are set; WPS registers itself as
  # the handler for Office documents.
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "google-chrome.desktop";
      "application/xhtml+xml" = "google-chrome.desktop";
      "x-scheme-handler/http" = "google-chrome.desktop";
      "x-scheme-handler/https" = "google-chrome.desktop";
    };
  };
}
