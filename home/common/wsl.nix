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

  # Both WSL hosts keep one nixconfig checkout outside the homes. Permissions
  # differ per host (single-user vs. group-readable) and are set in
  # hosts/<host>; see the one-time setup in the README.
  submodules.repoRoot = "/srv/nixconfig";

  # The checkout may be owned by another user, so git would otherwise reject
  # it as "dubious ownership". That is handled once, in the system-wide git
  # config — see the `safe.directory` comment in hosts/<host>/default.nix. Do
  # not re-add it here: git reads system -> global -> local and safe.directory
  # is multi-valued, so a second copy would only drift out of sync.
}
