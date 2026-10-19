# LLM coding agents from numtide/llm-agents.nix.
#
# Import this from a host (or from modules/nixos/common.nix to make the tools
# available everywhere). Uses llm-agents.nix's own pinned nixpkgs-unstable, so
# keep `llm-agents` independent (no `nixpkgs.follows`) in flake.nix.

{ inputs, pkgs, ... }:

let
  llm = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  # Numtide binary cache — get pre-built binaries instead of compiling.
  nix.settings = {
    extra-substituters = [ "https://cache.numtide.com" ];
    extra-trusted-public-keys = [
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
    ];
  };

  environment.systemPackages = [
    llm.claude-code
    llm.opencode2
    llm.pi
    llm.antigravity-cli
  ];
}
