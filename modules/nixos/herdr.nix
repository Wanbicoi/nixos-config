# Herdr terminal workspace manager from herdrdev/herdr-nix.
#
# Uses herdr-nix's own pinned nixpkgs, so keep `herdr-nix` independent (no
# `nixpkgs.follows`) in flake.nix to get pre-built binaries from its cache.

{ inputs, pkgs, ... }:

{
  # Herdr binary cache — get pre-built binaries instead of compiling.
  nix.settings = {
    extra-substituters = [ "https://herdr.cachix.org" ];
    extra-trusted-public-keys = [
      "herdr.cachix.org-1:3nH7IStRsS0ASfdonA0DCRR2ZrSCeWitZ7Kwew0cR4I="
    ];
  };

  environment.systemPackages = [
    inputs.herdr-nix.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
