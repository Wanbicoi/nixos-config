# nixconfig

Declarative configuration for my machines — NixOS laptops, NixOS-WSL, and
(eventually) macOS via nix-darwin — built on flakes and Home Manager.

## Layout

| Path | Purpose |
| --- | --- |
| `flake.nix` | Inputs and host registry (`nixosConfigurations`, later `darwinConfigurations`). |
| `hosts/<name>/` | One directory per machine: hostname, platform modules, users. |
| `modules/nixos/` | NixOS system modules shared by all machines. |
| `modules/darwin/` | nix-darwin modules (placeholder). |
| `home/common/` | Home Manager modules shared by every user profile. |
| `home/<user>/` | Per-user identity and user-specific packages. |
| `secrets/` | Age-encrypted secrets, decrypted at activation by sops-nix. See [`secrets/README.md`](secrets/README.md). |

## Machines

| Attribute | Platform | Notes |
| --- | --- | --- |
| `wsl` | NixOS-WSL | personal, user `nixos` |
| `wsl-laidon` | NixOS-WSL | Laidon, user `troy` |

## Usage

```bash
# apply a host (defaults to HOST=wsl)
sudo nixos-rebuild switch --flake .#wsl
sudo nixos-rebuild switch --flake .#wsl-laidon

# update all inputs, then re-apply
nix flake update
sudo nixos-rebuild switch --flake .#wsl
```

## Secrets

Secrets are committed encrypted under `secrets/` and decrypted at activation
with sops + age. The private key is **not** in the repo — it lives at
`~/.config/sops/age/keys.txt` (back it up).

```bash
make secrets-edit        # edit encrypted secrets/env template
make switch              # sops-nix decrypts during rebuild
```

See [`secrets/README.md`](secrets/README.md) for key setup, adding a secret,
wiring it into Home Manager, and rekeying.

## Adding a machine

- **NixOS:** create `hosts/<name>/default.nix`, then add
  `nixosConfigurations.<name> = mkNixos "<name>" "x86_64-linux";` to `flake.nix`.
  See `hosts/README.md`.
- **macOS:** uncomment the `nix-darwin` input and follow
  `modules/darwin/README.md`.
