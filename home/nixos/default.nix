# Home Manager entrypoint for user `nixos`.
#
# Identity is per-user; everything else is shared via ../common. Platform
# tooling stays out of here: WSL hosts also import ../common/wsl.nix, a native
# NixOS host does not, so the same profile works on both.
{ ... }:

{
  imports = [
    ../common
    ./identity.nix
    ./secrets.nix
  ];
}
