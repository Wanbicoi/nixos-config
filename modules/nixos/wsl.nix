# NixOS-WSL platform settings, shared by all WSL machines.

{ ... }:

{
  wsl.enable = true;

  # Default user is per-host (hosts/<name>/default.nix).
}
