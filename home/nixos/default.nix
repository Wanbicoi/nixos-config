# Home Manager entrypoint for user `nixos`.
#
# This is a thin aggregator: each sibling file is a standalone Home Manager
# module covering one concern. Add new user config there, not here.
{ ... }:

{
  imports = [
    ./identity.nix
    ./secrets.nix
    ./submodules.nix
    ./shell.nix
    ./programs.nix
    ./packages.nix
  ];
}
