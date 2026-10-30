# Journals client wrapper.
#
# The server is a system service (modules/nixos/journals.nix) configured by
# /etc/journals/config.yaml. The TUI only speaks HTTP to it, so every user on
# the machine sees the same journal.
{ config, pkgs, ... }:

let
  journalsRepo = "${config.submodules.repoRoot}/submodules/journals";
in
{
  home.packages = [
    (pkgs.writeShellApplication {
      name = "journals";
      runtimeInputs = [ pkgs.bun ];
      text = ''
        export JOURNAL_CONFIG=/etc/journals/config.yaml
        exec bun ${journalsRepo}/packages/client-tui/src/index.tsx "$@"
      '';
    })
  ];
}
