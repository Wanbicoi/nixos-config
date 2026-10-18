# Home Manager entrypoint for user `troy` (Laidon WSL).
#
# Same base as the personal profile, plus Laidon-specific tooling.
{ ... }:

{
  imports = [
    ../common
    ../common/wsl.nix
    ./identity.nix
    ./packages.nix
  ];
}
