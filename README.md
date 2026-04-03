# NixOS config (flake + Home Manager)

This repo manages the full system config for host `nixos`.

## Layout

- `flake.nix`: flake entrypoint.
- `hosts/nixos/default.nix`: host-level imports and state version.
- `hosts/nixos/hardware-configuration.nix`: generated hardware config for this host.
- `modules/system/*`: reusable NixOS modules.
- `home/trung/*`: Home Manager config for user `trung`.

## First-time setup

```bash
sudo mv /etc/nixos ~/nixos-config
sudo chown -R "$USER":users ~/nixos-config
sudo ln -s ~/nixos-config /etc/nixos
```

## Rebuild

```bash
cd ~/nixos-config
sudo nixos-rebuild switch --flake .#nixos
```

## Update flake inputs

```bash
cd ~/nixos-config
nix flake update
sudo nixos-rebuild switch --flake .#nixos
```

## Notes

- User apps/tooling are managed via Home Manager in `home/trung`.
- Node backend tools are in `home/trung/dev.nix` (`nodejs_22`, `httpie`).
- Add more modules later by creating files and importing them from host or home config.