# Secrets (sops + age)

Secrets are stored **encrypted in this repo** and decrypted on the target
machine at activation by [sops-nix](https://github.com/Mic92/sops-nix). Only
the age *public* keys are committed; private keys never leave the machine.

Each persona has its own namespace, so one leaked key decrypts at most that
persona's secrets:

- `secrets/personal.yaml` — personal profile (`nixos`), personal key only
- `secrets/laidon.yaml` — Laidon company profile (`troy`), Laidon key only
- `../.sops.yaml` — which age recipient(s) may decrypt which path
- `../home/<user>/secrets.nix` — that profile's `defaultSopsFile` + declared
  secrets; `../home/common/secrets.nix` only wires in sops-nix and the key path

## Key setup

Each user needs its own private key at `~/.config/sops/age/keys.txt` (sops and
sops-nix both read this path by default). The keys are **not the same** — the
personal key is `age1mggn…`, the Laidon key is `age1k6ka…`. **Back both up
somewhere safe** — without a key the committed secrets it decrypts cannot be
recovered.

First time on a machine:

```bash
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt
```

`age-keygen` prints the matching public key (`age1...`) to stderr. To let this
key decrypt an existing namespace add it as a recipient in `../.sops.yaml`,
then rekey (see [Rekeying](#rekeying)). Otherwise, restore each persona's
`keys.txt` from backup.

## Adding or editing a secret

```bash
make secrets-edit                 # == sops secrets/personal.yaml
sops secrets/laidon.yaml          # edit the Laidon namespace directly
```

This opens the file decrypted in `$EDITOR`; saving re-encrypts it using the
rules in `../.sops.yaml`. A plain `key: value` line is all that is needed:

```yaml
example_secret: hunter2
```

Then declare it in the matching `home/<user>/secrets.nix`. **Adding the key to
the YAML does nothing on its own** — sops-nix only decrypts names declared
under `sops.secrets`, and only exports the ones a template references:

```nix
sops.secrets.my_token = { };          # decrypt to the sops runtime dir

sops.templates."shell.env".content = ''
  export MY_TOKEN="${config.sops.placeholder.my_token}"
'';
```

- Use `config.sops.placeholder.<name>` inside templates (the value is
  substituted at activation, so it never enters the Nix store).
- For a plain file instead, reference `config.sops.secrets.<name>.path`
  (default `~/.config/sops-nix/secrets/<name>`).
- Extra per-secret options live under `sops.secrets.<name>`: `owner`, `group`,
  `mode`, `path`, `key`, etc.

## Rekeying

Any time the recipient list in `../.sops.yaml` changes (e.g. you added a new
machine's public key), re-encrypt the existing secrets so the new key can read
them:

```bash
sops updatekeys secrets/personal.yaml
sops updatekeys secrets/laidon.yaml
# or, for every file:
sops updatekeys secrets/*.yaml
```

Commit the updated ciphertext afterwards.

## Activating

sops-nix decrypts on activation, so apply it with a normal rebuild:

```bash
make switch          # sudo nixos-rebuild switch --flake .#wsl
```

Per user, the decrypted files and rendered templates are staged in that user's
runtime dir, reachable through a symlink:

```
~/.config/sops-nix/secrets -> $XDG_RUNTIME_DIR/secrets.d/<n>/
  CF_USERNAME           one file per `sops.secrets.<name>` (troy)
  rendered/shell.env    one file per `sops.templates."<name>"`
```

Home Manager does that work in a **user service** (`systemctl --user restart
sops-nix`). Its activation script checks `systemctl --user is-system-running`
first, and when no user manager is running it prints

```
User systemd daemon not running. Probably executed on boot where no manual
start/reload is needed.
```

and then **skips the render entirely** — `home-manager-<user>.service` still
reports success, so the failure is silent. A user who is only ever entered with
`sudo -iu <user>` or `wsl.exe -u <user>` (never a login session) has no user
manager, and therefore no secrets. Declare `users.users.<user>.linger = true;`
(see `../hosts/wsl-laidon/default.nix`, where both `nixos` and `troy` do) so
the manager starts at boot.

Each user needs its own `~/.config/sops/age/keys.txt`; one user's key does not
decrypt for another.

The rendered templates are sourced from `programs.zsh.envExtra`, i.e.
`~/.zshenv` — **zsh only**. Run `exec zsh -l` in an already-open shell after a
switch.

## Troubleshooting

- `sops` can't decrypt → the `age1...` in `.sops.yaml` for that namespace has
  no matching key in `~/.config/sops/age/keys.txt`. Restore the key or add
  yours + rekey.
- `make secrets-edit` opens garbage → the file is still encrypted; sops
  decrypts automatically once the key is present.
- `echo $MY_TOKEN` prints nothing → the key is inert unless all five links are
  in place:
  1. the key exists in the right namespace file (`secrets/<persona>.yaml`);
  2. it is **declared** as `sops.secrets.<name>` in that profile's
     `home/<user>/secrets.nix` (a key that only sits in the YAML is the most
     common cause);
  3. a template exports `${config.sops.placeholder.<name>}`;
  4. the shell reading it is zsh (`~/.zshenv`) — other shells, scripts and
     systemd units should read `~/.config/sops-nix/secrets/<name>`;
  5. the user's user manager is running — see [Activating](#activating).

  Diagnostics: `ls ~/.config/sops-nix/secrets/`,
  `systemctl --user status sops-nix`, and in a fresh shell
  `zsh -c 'printf "%s\n" "${MY_TOKEN:+set}"'`. Print lengths or `set`/`unset`
  markers when checking — never the value itself, it ends up in logs.
- Value has a trailing newline → use `sops.templates` (or strip it in the
  consuming command); use `_unencrypted` suffixes as needed for non-secret
  metadata keys.
