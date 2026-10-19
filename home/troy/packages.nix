# Laidon-specific user packages for `troy`.
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # GitLab CLI
    glab

    # Cloud Foundry CLI (`cf`)
    cloudfoundry-cli

    # Atlassian CLI (`acli`). Unfree; the nixpkgs license gate is opened by a
    # scoped predicate in hosts/wsl/default.nix.
    acli

    # SAP HANA Developer CLI (packaged locally for offline use).
    (callPackage ./hana-cli { })
  ];
}
