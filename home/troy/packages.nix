# Laidon-specific user packages for `troy`.
#
# Most tools come from nixpkgs. `hana-cli` (SAP HANA Developer CLI) is only
# published on npm and ships without a package-lock.json, so `buildNpmPackage`
# cannot be used reproducibly. Wrapping npx is the pragmatic option.
{ pkgs, ... }:

let
  # Upstream: https://www.npmjs.com/package/hana-cli
  # Runs through npx so it stays current without a mutable global npm install.
  hana-cli = pkgs.writeShellScriptBin "hana-cli" ''
    exec ${pkgs.nodejs}/bin/npx --yes hana-cli@latest "$@"
  '';
in
{
  home.packages = with pkgs; [
    # GitLab CLI
    glab

    # Cloud Foundry CLI (`cf`)
    cloudfoundry-cli

    # SAP HANA Developer CLI (npm, wrapped above).
    hana-cli
  ];
}
