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

## WSL: personal vs company-first distro

`wsl` is single-user: `nixos` is the default user and the only account.
`wsl-laidon` makes the company persona (`troy`) the default user so Explorer,
VS Code and a bare `wsl.exe` all land there, leaving `nixos` as the admin
entered with `wsl.exe -u nixos`. Because `wsl.defaultUser` also adds
`wheel`, that host `mkForce`s the default user's `extraGroups`; keep the same
guard if you add another company-first distro.

## Add a Mac (nix-darwin)

See `../modules/darwin/README.md`, then register the host under
`darwinConfigurations` in `flake.nix`.
