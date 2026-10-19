# WSL-only user tooling: clipboard bridge and Windows app/file openers.
#
# Imported by WSL hosts only (see home/nixos and home/troy), not by the
# platform-agnostic modules in home/common/default.nix.
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Wayland clipboard (wl-copy/wl-paste). WSLg exposes a Wayland socket,
    # which bridges to the Windows clipboard.
    wl-clipboard

    # xdg-open/xdg-mime/xdg-settings for apps that shell out to them.
    xdg-utils

    # Actually opens files/URLs with the Windows default applications.
    wsl-open
  ];

  # xdg-open consults $BROWSER for URLs; point it at the Windows opener.
  home.sessionVariables.BROWSER = "wsl-open";

  # Every WSL user shares one nixconfig checkout outside the homes. The group
  # (nixconfig) and permissions are set in hosts/<host>; see the one-time
  # setup in the README.
  submodules.repoRoot = "/srv/nixconfig";

  # The shared checkout is owned by another user, so git (and the flake
  # evaluation during nixos-rebuild) would otherwise reject it as
  # "dubious ownership". /srv/shared is the cross-identity workspace (declared
  # in hosts/wsl/default.nix) and gets the same treatment, since repos cloned
  # there by one user will be touched by the other.
  programs.git.settings.safe.directory = [
    "/srv/nixconfig"
    "/srv/shared"
  ];
}
