# hosts/<name>/

One directory per machine. Each `default.nix`:

- imports the platform modules it needs (`../../modules/nixos/...`),
- sets machine-specific values (`networking.hostName`, user, `system.stateVersion`),
- attaches Home Manager user profiles (`../../home/<user>`).

## Add a NixOS laptop

```nix
# flake.nix
thinkbook = mkNixos "thinkbook" "x86_64-linux";
```

Then create `hosts/thinkbook/default.nix` (copy `hosts/wsl/default.nix`,
swap `nixos-wsl` modules for `nixos-hardware`/a hardware-configuration.nix).

## Add a Mac (nix-darwin)

See `../modules/darwin/README.md`, then register the host under
`darwinConfigurations` in `flake.nix`.
