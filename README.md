# NixOS config (flake + Home Manager)

This repo manages the full system config for host `thinkpad` and a minimal WSL target.

## Layout

- `flake.nix`: flake entrypoint.
- `hosts/laptop-thinkbook-14-g6-irl/default.nix`: laptop host config.
- `hosts/wsl/default.nix`: WSL host config.
- `modules/*`: reusable NixOS/Home Manager modules.

## First-time setup

```bash
sudo mv /etc/nixos ~/nixos-config
sudo chown -R "$USER":users ~/nixos-config
sudo ln -s ~/nixos-config /etc/nixos
```

## Rebuild

Laptop:
```bash
cd ~/nixos-config
sudo nixos-rebuild switch --flake .#thinkpad
```

WSL:
```bash
cd ~/nixos-config
sudo nixos-rebuild switch --flake .#wsl
```

## Update flake inputs

```bash
cd ~/nixos-config
nix flake update
sudo nixos-rebuild switch --flake .#thinkpad
```

## Notes

- WSL uses `hosts/wsl/default.nix` with `wsl.enable = true;` and a smaller Home Manager profile.
- Node backend tools are in `modules/applications/dev.nix`.
- Add more modules later by creating files and importing them from host or home config.
