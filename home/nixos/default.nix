# Home Manager entrypoint for user `nixos`.
#
# Identity is per-user; everything else is shared via ../common.
{ ... }:

{
  imports = [
    ../common
    ./identity.nix
  ];
}
