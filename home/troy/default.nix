# Home Manager entrypoint for user `troy` (Laidon WSL).
#
# Same base as the personal profile, plus Laidon-specific tooling. The WSL
# platform module is attached by hosts/wsl-laidon, so this profile stays tied
# to the persona rather than to the distro.
{ ... }:

{
  imports = [
    ../common
    ./identity.nix
    ./packages.nix
    ./secrets.nix
  ];
}
