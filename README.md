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
| `wsl` | NixOS-WSL | one distro; default user `nixos` (personal) plus company profiles (currently `troy`) |

## Fresh setup

Bootstrap for a new machine, from a stock install to this config taking over.
NixOS-WSL is shown; a laptop also needs its own host first (see "Adding a
machine").

1. **Enable flakes.** A fresh install is still managed by
   `/etc/nixos/configuration.nix`, and `sudo nixos-rebuild --flake` needs
   flakes enabled for root. Add the feature and activate once:

   ```nix
   # /etc/nixos/configuration.nix
   nix.settings.experimental-features = [ "nix-command" "flakes" ];
   ```

   ```bash
   sudo nixos-rebuild switch
   ```

2. **Clone the checkout with its submodules** (use the SSH URL and
   `--recurse-submodules` if you also push from this machine):

   ```bash
   git clone --recurse-submodules https://github.com/Wanbicoi/nixos-config ~/nixconfig
   cd ~/nixconfig
   ```

3. **Restore the sops age key** to `~/.config/sops/age/keys.txt` (mode `0400`)
   *before* the first activation: sops-nix decrypts during the rebuild, and any
   home without a key fails its Home Manager unit. To restore from backup, or
   to generate a key and rekey, see [`secrets/README.md`](secrets/README.md).

4. **Activate:**

   ```bash
   make switch          # sudo nixos-rebuild switch --flake .#wsl
   ```

   The first rebuild runs as an untrusted user, so it ignores the flake's
   `nixConfig` (extra substituter, `accept-flake-config`, `trusted-users`) and
   may build more from source than later ones. Those settings apply from the
   next switch onwards.

5. **Move the checkout to its shared location** (NixOS-WSL) following
   [Shared checkout](#shared-checkout) — the `chgrp`/`chmod` step is what lets
   every user read the flake and write the submodules. A laptop can keep the
   checkout in `~` and skip this.

6. **Verify:**

   ```bash
   systemctl status home-manager-nixos     # "active (exited)"
   ```

## Usage

```bash
# apply the host (run from the checkout, e.g. /srv/nixconfig)
sudo nixos-rebuild switch --flake .#wsl

# update all inputs, then re-apply
nix flake update
sudo nixos-rebuild switch --flake .#wsl
```

## Users

`nixos` is the personal profile and the WSL default user (uid 1000). Company
profiles are extra users on the same distro: `troy` is Laidon, and a new
company means a new `home/<user>/` profile plus one `users.users.<user>` block
in `hosts/wsl/default.nix`.

Enter a non-default user with `wsl.exe -d <distro> -u <user>` from Windows or
`su - <user>` inside.

### Adding a company user

1. Copy the profile: `cp -r home/troy home/<company>`, then edit
   `home/<company>/identity.nix` (`username`, `homeDirectory`) and
   `home/<company>/packages.nix` (the company's CLI/tooling).
2. Register the user and its Home Manager profile in `hosts/wsl/default.nix`
   (next free uid — 1000 is `nixos`, 1001 is `troy`):

   ```nix
   users.users.<company> = {
     isNormalUser = true;
     uid = 1002;
     extraGroups = [ "wheel" "nixconfig" ];
     shell = pkgs.zsh;
   };
   # ...
   home-manager.users.<company>.imports = [ ../../home/<company> ];
   ```

3. Rebuild once, then give the new home a sops age key and restart its unit —
   the first activation fails because the key is missing:

   ```bash
   sudo nixos-rebuild switch --flake /srv/nixconfig#wsl
   sudo -u <company> install -d -m 0700 /home/<company>/.config/sops/age
   sudo -u <company> install -m 0400 \
     /home/nixos/.config/sops/age/keys.txt \
     /home/<company>/.config/sops/age/keys.txt
   sudo systemctl restart home-manager-<company>.service
   ```

   Run the copy **as the new user** so ownership is right. A plain
   `sudo install -o <uid> ...` only applies `-o`/`-g` to the last path
   component, leaving parent directories root-owned — which then breaks Home
   Manager with `mkdir: Permission denied`.

## Shared checkout

All users share a single nixconfig checkout at `/srv/nixconfig` (set via
`submodules.repoRoot` in `home/common/wsl.nix`) so the submodules and agent
state are not duplicated per home. It lives outside the homes and is owned by
the `nixconfig` group. One-time setup — note the order: the group only exists
after the first rebuild, so `chgrp` comes after it.

```bash
# 1. Move the checkout to the shared location.
sudo mv ~/nixconfig /srv/nixconfig

# 2. Apply once: creates the nixconfig group + users and points their
#    submodule symlinks at /srv/nixconfig. A user without a sops age key will
#    have its Home Manager unit fail here; seed the key as that user and
#    restart the unit (see "Adding a company user" above).
sudo nixos-rebuild switch --flake /srv/nixconfig#wsl

# 3. Hand the checkout to the group and keep it group-writable.
sudo chgrp -R nixconfig /srv/nixconfig
sudo chmod -R g+rwX    /srv/nixconfig
sudo find /srv/nixconfig -type d -exec chmod g+s {} +
git -C /srv/nixconfig submodule update --init --recursive
```

The sops age key is **not** in the repo; each home needs its own copy at
`~/.config/sops/age/keys.txt` (see below). `umask 002` (set in
`home/common/shell.nix`) keeps newly written files group-writable.

## Shared folder

Homes are private: `/home/nixos` is 0700 and `/home/troy` is 0750 (browsable
only, so Windows Explorer can list it). Anything both identities should read
*and* write belongs in `/srv/shared` instead of a home directory, which
avoids relaxing permissions on `~/.ssh`, sops age keys, or browser sessions.

`/srv/shared` is declared in `hosts/wsl/default.nix` as a `systemd.tmpfiles`
rule: `d /srv/shared 2775 root shared -`. The setgid bit means files created
below it inherit the `shared` group regardless of which user made them, and
`umask 002` gives them group write. Apart from that nothing to set up — the
directory appears on the next `make switch`:

```bash
cd /srv/shared
mkdir project && ls -ld .      # drwxrwsr-x ... root shared
```

Do not fix cross-user access by recursively `chmod`-ing a home: that opens
everything (including 0600 secrets) or is masked out on exactly those files,
so it either over-shares or achieves nothing. Move the data here instead.

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
