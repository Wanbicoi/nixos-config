# Home Manager entrypoint for user `merry` (merry-laptop).
#
# Deliberately does not import ../common: that profile is the developer setup
# (neovim, agent configs, journals, rust/go toolchains), which would only
# clutter a KDE application menu. Browser/office apps live in packages.nix;
# desktop apps that Plasma already ships are not repeated there.
{ inputs, ... }:

{
  imports = [
    # Unofficial Zalo client (no official Linux build): the flake packages the
    # upstream AppImage and exposes the `programs.zalo` module.
    inputs.zalo-for-linux.homeModules.default

    ./identity.nix
    ./packages.nix
  ];

  programs.zalo.enable = true;

  home.stateVersion = "26.05";
}
