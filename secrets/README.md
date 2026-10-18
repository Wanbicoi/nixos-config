# Secrets (sops + age)

Secrets are stored **encrypted in this repo** and decrypted on the target
machine at activation by [sops-nix](https://github.com/Mic92/sops-nix). Only
the age *public* key is committed; the private key never leaves the machine.

- `secrets/*.yaml` — encrypted values (safe to commit)
- `../.sops.yaml` — which age recipient(s) may decrypt which paths
- `../home/nixos/secrets.nix` — declares secrets to Home Manager and templates

## Key setup

The private key lives **outside the repo** at
`~/.config/sops/age/keys.txt` (sops and sops-nix both read this path by
default). **Back it up somewhere safe** — without it the committed secrets
cannot be decrypted.

First time on a machine:

```bash
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt
```

`age-keygen` prints the matching public key (`age1...`) to stderr. To let this
key decrypt the existing secrets add it as a recipient in `../.sops.yaml`, then
rekey (see [Rekeying](#rekeying)). Otherwise, restore an existing `keys.txt`
from your backup.

## Adding or editing a secret

```bash
make secrets-edit                 # == sops secrets/common.yaml
```

This opens the file decrypted in `$EDITOR`; saving re-encrypts it using the
rules in `../.sops.yaml`. A plain `key: value` line is all that is needed:

```yaml
example_secret: hunter2
```

Then wire it into Home Manager in `home/nixos/secrets.nix`:

```nix
sops.secrets.my_token = { };          # decrypt to the sops runtime dir

sops.templates."shell.env".content = ''
  export EXAMPLE_SECRET="${config.sops.placeholder.example_secret}"
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
sops updatekeys secrets/common.yaml
# or, for every file:
sops updatekeys secrets/*.yaml
```

Commit the updated ciphertext afterwards.

## Activating

sops-nix decrypts on activation, so apply it with a normal rebuild:

```bash
make switch          # sudo nixos-rebuild switch --flake .#wsl
```

The decrypted values are staged under `~/.config/sops-nix/secrets/` and the
rendered templates (e.g. `shell.env`) are sourced from `programs.zsh.envExtra`.

## Troubleshooting

- `sops` can't decrypt → the `age1...` in `.sops.yaml` has no matching key in
  `~/.config/sops/age/keys.txt`. Restore the key or add yours + rekey.
- `make secrets-edit` opens garbage → the file is still encrypted; sops
  decrypts automatically once the key is present.
- Value has a trailing newline → use `sops.templates` (or strip it in the
  consuming command); use `_unencrypted` suffixes as needed for non-secret
  metadata keys.
