# Laidon-specific user packages for `troy`.
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # GitLab CLI
    glab

    # Cloud Foundry CLI (`cf`)
    cloudfoundry-cli

    # Atlassian CLI (`acli`). Unfree; the nixpkgs license gate is opened by a
    # scoped predicate in hosts/wsl-laidon/default.nix.
    acli

    # SAP HANA Developer CLI (packaged locally for offline use).
    (callPackage ./hana-cli { })

    # SAP Cloud Application Programming Model (CAP) CLI (`cds` / `cds-dk`).
    (writeShellApplication {
      name = "cds";
      runtimeInputs = [
        nodejs
        pnpm
      ];
      text = ''
        exec pnpm dlx --package=@sap/cds-dk cds "$@"
      '';
    })
    (writeShellApplication {
      name = "cds-dk";
      runtimeInputs = [
        nodejs
        pnpm
      ];
      text = ''
        exec pnpm dlx --package=@sap/cds-dk cds "$@"
      '';
    })
  ];
}
