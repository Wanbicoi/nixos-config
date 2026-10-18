# Laidon-specific user packages for `troy`.
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # GitLab CLI
    glab

    # Cloud Foundry CLI (`cf`)
    cloudfoundry-cli

    # SAP HANA Developer CLI (packaged locally for offline use).
    (callPackage ./hana-cli { })
  ];
}
