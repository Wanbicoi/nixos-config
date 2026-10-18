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
    ./packages.nix
  ];
}
