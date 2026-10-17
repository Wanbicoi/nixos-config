# nix-darwin modules

Placeholder for macOS machines.

To enable macOS support:

1. Uncomment the `nix-darwin` input in `flake.nix`.
2. Create `hosts/<name>/default.nix` with `imports = [ ../../modules/darwin/... ]`.
3. Register it under `darwinConfigurations` in `flake.nix`.
4. Reuse `home/` modules for the user environment (Home Manager runs on
   nix-darwin too).
