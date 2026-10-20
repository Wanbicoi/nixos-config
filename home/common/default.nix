# Shared Home Manager modules used by every user profile.
#
# Per-user identity lives in home/<user>/identity.nix; everything here must be
# user-agnostic (derive paths from config.home.homeDirectory).
{ ... }:

{
  imports = [
    ./secrets.nix
    ./submodules.nix
    ./shell.nix
    ./programs.nix
    ./hunk.nix
    # ./herdr.nix # Disabled while testing; will declare with nix once config is mature
    ./packages.nix
  ];

  # Identical for every profile, so it is not part of identity.nix.
  home.stateVersion = "26.05";
  home.sessionVariables.EDITOR = "nvim";
}
