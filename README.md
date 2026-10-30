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
| `submodules/` | Config checkouts (`nvim`, `agent-config`, `lazygit`) plus the `journals` source used by its system service. |
| `secrets/` | Age-encrypted secrets, decrypted at activation by sops-nix. See [`secrets/README.md`](secrets/README.md). |

## Machines

| Attribute | Platform | Notes |
| --- | --- | --- |
| `wsl` | NixOS-WSL | personal distro; `nixos` is the only account (default user and admin) |
| `wsl-laidon` | NixOS-WSL | company-first distro; default user `troy` (no sudo), admin `nixos` via `wsl.exe -u nixos` |

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
   [Shared checkout](#shared-checkout). On `wsl-laidon` the `chgrp`/`chmod`
   step is what lets the company user read the flake; on personal `wsl` the
   checkout stays owner-only. A laptop can keep the checkout in `~` and skip
   this.

6. **Verify:**

   ```bash
   systemctl status home-manager-nixos     # "active (exited)"
   ```

## Usage

```bash
# apply the host (run from the checkout, e.g. /srv/nixconfig)
make switch            # personal wsl
make switch-laidon     # wsl-laidon, from inside that distro only
# equivalently:
sudo nixos-rebuild switch --flake .#wsl

# update all inputs, then re-apply
nix flake update
make switch
```

`switch-laidon` refuses to run unless the distro is named `wsl-laidon` (or is
already running that host, i.e. `hostname` is `wsl-laidon`): the host swaps the
`nixos`/`troy` uids, which is only safe in the company distro. Override the
expected name with `make switch-laidon LAIDON_DISTRO=<distro>`.

## Users

Two WSL hosts exist, with opposite defaults:

- `wsl` — personal distro. `nixos` is the only account: uid 1000, default user
  and admin.
- `wsl-laidon` — Laidon distro. `troy` is the default user (uid 1000, no sudo,
  so Explorer/VS Code/`wsl.exe` all open as the company persona) and `nixos`
  is the admin (uid 1001), entered with `wsl.exe -u nixos`. Both users have
  Home Manager profiles and `linger` enabled, because HM activates before the
  first login session; `troy`'s home stays 0700 because Explorer already runs
  as troy.

Company accounts belong on `wsl-laidon`, never on the personal `wsl` distro.
There, the default user is already the company persona; add another company by
following "Adding a company user" below.

Enter a non-default user with `wsl.exe -d <distro> -u <user>` from Windows or
`sudo -iu <user>` inside. `su - <user>` cannot work: `su` asks for the target
user's password, and no profile declares one (the accounts are locked `!` in
`/etc/shadow`).

### Adding a company user

1. Copy the profile: `cp -r home/troy home/<company>`, then edit
   `home/<company>/identity.nix` (`username`, `homeDirectory`) and
   `home/<company>/packages.nix` (the company's CLI/tooling).
2. Register the user and its Home Manager profile in
   `hosts/wsl-laidon/default.nix` (uids there: 1000 is `troy`, 1001 is
   `nixos`, so the next free one is 1002):

   ```nix
   users.users.<company> = {
     isNormalUser = true;
     uid = 1002;
     extraGroups = [ "nixconfig" "shared" ];  # NO "wheel": see below
     shell = pkgs.zsh;
   };
   # ...
   home-manager.users.<company>.imports = [ ../../home/<company> ];
   ```

   Company users are deliberately **not** in `wheel`: no `sudo`, no
   trusted-user status. `nixos` is the only admin and the only user who runs
   `make switch`; a company persona enters its home with `wsl.exe -u <company>`
   or `sudo -iu <company>` (run by nixos).

3. Rebuild once, then give the new home a sops age key and restart its unit —
   the first activation fails because the key is missing. Each persona has its
   **own** key (see "Secrets" below), so generate one rather than copying
   nixos's:

   ```bash
   sudo nixos-rebuild switch --flake /srv/nixconfig#wsl-laidon
   sudo -u <company> mkdir -p /home/<company>/.config/sops/age
   sudo -u <company> age-keygen -o /home/<company>/.config/sops/age/keys.txt
   # add its `age1...` public key as a new recipient in .sops.yaml, then rekey:
   # sops updatekeys secrets/<company>.yaml
   sudo systemctl restart home-manager-<company>.service
   ```

   Run the key generation **as the new user** so ownership is right. A plain
   `sudo install -o <uid> ...` only applies `-o`/`-g` to the last path
   component, leaving parent directories root-owned — which then breaks Home
   Manager with `mkdir: Permission denied`.

## Shared checkout

Both hosts keep the nixconfig checkout at `/srv/nixconfig` (set via
`submodules.repoRoot` in `home/common/wsl.nix`). On the personal `wsl` distro
only `nixos` exists, but the tree is still `2750 nixos:nixconfig`: only `nixos`
writes it, and the `journals` system user reads it through the `nixconfig`
group (`tmpfiles` `z` rule in `hosts/wsl/default.nix`, see
`modules/nixos/journals.nix`). The journal database itself is outside the
checkout, at `/srv/shared/journals/`.

On `wsl-laidon`, nixos still **owns** it, but company users are in the
`nixconfig` group only so they can **read** it — never write it, because root
re-uses the checkout when evaluating the flake and activating the system, so
write access would be equivalent to root. That tree is `2750 nixos:nixconfig`
(`hosts/wsl-laidon/default.nix`).

One-time setup for `wsl-laidon` — note the order: the group only exists after
the first rebuild.

```bash
# 1. Move the checkout to the shared location.
sudo mv ~/nixconfig /srv/nixconfig

# 2. Apply once: creates the nixconfig group + users and (via tmpfiles) sets
#    the 2750 mode. A user without a sops age key will have its Home Manager
#    unit fail here.
sudo nixos-rebuild switch --flake /srv/nixconfig#wsl-laidon

# 3. Ensure the checkout is group-readable (idempotent).
sudo chgrp -R nixconfig /srv/nixconfig
sudo chmod -R u+rwX,g+rX,o-rwx /srv/nixconfig
git -C /srv/nixconfig submodule update --init --recursive
```

Agent state (Pi `auth.json`/`sessions/`/`npm/`, etc.) is **per-user**: it lives
in each home's own `~/.pi/agent`, never in the shared checkout (see
`home/common/submodules.nix`). The checkout holds only the portable declarative
config that gets linked into each home read-only.

## Shared folder

This exists only on `wsl-laidon`, where two identities coexist. Homes stay
private: `/home/troy` is 0700 (Explorer runs as troy, so it needs no browse
grant) and `/home/nixos` is 0700. Anything both identities should read *and*
write belongs in `/srv/shared` instead of a home directory, which avoids
relaxing permissions on `~/.ssh`, sops age keys, or browser sessions. The
personal `wsl` distro has one user and no `/srv/shared`.

`/srv/shared` is declared in `hosts/wsl-laidon/default.nix` as `systemd.tmpfiles`
rules: `d /srv/shared 2775 root shared -` plus default ACLs
(`g:shared:rwx`, `d:g:shared:rwx`). The setgid bit makes new entries inherit
the `shared` group, and the default ACL grants that group write regardless of
the creator's umask — no `umask 002` needed anywhere. Apart from that nothing
to set up — the directory appears on the next `make switch`:

```bash
cd /srv/shared
mkdir project && ls -ld .      # drwxrwsr-x ... root shared
```

Do not fix cross-user access by recursively `chmod`-ing a home: that opens
everything (including 0600 secrets) or is masked out on exactly those files,
so it either over-shares or achieves nothing. Move the data here instead.

## Journals

The journals daemon runs as the `journals` system user on boot and owns
`/srv/shared/journals/data.sqlite` (`modules/nixos/journals.nix`). The TUI
(`journals`) only talks to it over `127.0.0.1`, so every user on a machine
shares one journal. The same `db_path` is used on both distros, but each
distro has its own data; on `wsl-laidon` `nixos` and `troy` share one DB.

- Ports: `4321` on `wsl`, `4323` on `wsl-laidon` (both distros may run at once).
- Config is declarative at `/etc/journals/config.yaml`; do not edit it by hand.
- Logs: `journalctl -u journals`; control: `sudo systemctl {status,restart} journals`.
- After checking out or updating the submodule, run `make journals-deps` and
  then `sudo systemctl restart journals`.

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
