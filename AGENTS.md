# AGENTS.md

Navigation only. `README.md` (layout, fresh setup), `hosts/README.md` and
`secrets/README.md` are the prose docs; `Makefile` is the command surface
(`make help`).

## Where things live

- `flake.nix` — inputs and host registry.
- `hosts/<host>/default.nix` — machine specifics: hostname, `stateVersion`,
  users/groups, Home Manager user → profile wiring. Keep these out of modules.
- `modules/nixos/` — system modules shared by every host (platform-generic).
- `home/common/` — Home Manager modules for every user profile;
  `home/<user>/` — per-user identity (git name/email) and packages.
- `secrets/` — encrypted values; read `secrets/README.md` before touching.
- `submodules/` — `nvim` and `agent-config` checkouts, linked out-of-store into
  `$HOME` by `home/common/submodules.nix` (`submodules.repoRoot`, set to
  `/srv/nixconfig`). `~/.agents/skills`, `~/.pi/agent`, `~/.config/nvim` etc.
  point into them, so those files belong to *other* repos.

## Flake outputs

- `nixosConfigurations.wsl` (personal) and `nixosConfigurations.wsl-laidon`
  (company-first) — the two WSL hosts. There is **no** `homeConfigurations`
  output and no `packages.*`; Home Manager is integrated through NixOS.
- Per-user Home Manager config lives at
  `nixosConfigurations.<host>.config.home-manager.users.<user>.home.*`
  (users: `nixos`, `troy`).

## Verify before activating

- `nix flake check` — evaluates all outputs + formatter check, ~20 s.
- Home Manager change only:
  `nix build .#nixosConfigurations.wsl.config.home-manager.users.<user>.home.activationPackage`
- System change:
  `nix build .#nixosConfigurations.wsl.config.system.build.toplevel`
- What would change: `make dry` (dry-activate).
- Read the built result instead of guessing: `<out>/etc/...` for system files,
  `/nix/store/*-home-manager-generation/{activate,home-files/...}` for Home
  Manager. `/nix/store/*-hm_..zshrc` is the generated zsh config.
- Activate: `make switch` (already wraps `sudo nixos-rebuild`). **Never**
  `sudo make switch` — that runs make and hooks as root over a shared checkout.
  `sudo` is passwordless on this host.

## Reading upstream (pinned input) modules

Option definitions beat recollection; read the module from the flake inputs:

- input checkouts: `nix flake archive --json | jq -r '.inputs | to_entries[] | "\(.key) \(.value.path)"'`
- nixpkgs source: `nix eval --raw nixpkgs#path`
- Home Manager modules: `<home-manager path>/modules/programs/<name>.nix`
- NixOS modules: `<nixpkgs path>/nixos/modules/...`

## WSL host specifics (`wsl`, `wsl-laidon`)

- `/etc` is a symlink into the store and **read-only**: hand edits
  (`git config --system ...`, files dropped in `/etc`) never persist. Change the
  module and switch, or pass an env override for a one-off
  (`GIT_CONFIG_GLOBAL=...`).
- `su - <user>` does not work here: `su` authenticates as the *target* user via
  PAM, and no profile declares a password hash (all accounts are `!` = locked in
  `/etc/shadow`), so the prompt can never be satisfied. Use `sudo -iu <user>`
  (run as nixos) or `wsl.exe -u <user>`. `nixos` is the only `wheel`/sudo user
  on both hosts, so `make switch` is a nixos-only action. On `wsl-laidon`,
  `troy` is the default but non-admin user (see the `mkForce` in that host).
- `/srv/nixconfig` is a git checkout owned by `nixos`. Personal `wsl` is
  single-user and keeps it `0700`. On `wsl-laidon` company users are in the
  `nixconfig` group but only to **read** it (mode `2750`), never write it,
  because root re-uses the checkout when evaluating the flake and activating —
  write access to it would be root. Hence the `safe.directory` entries in both
  hosts. Repos under `/srv/shared` (wsl-laidon only) have their own
  cross-identity ownership mix.
- Both users have `users.users.<user>.linger = true` on `wsl-laidon`.
  Home Manager's system unit runs before `systemd-user-sessions.service`, so
  even the default user (troy) has no user manager yet at boot; without linger
  HM skips the user units and sops secrets never render. nixos is additionally
  never a login session (entered with `sudo -iu nixos` or `wsl.exe -u nixos`).
  See `secrets/README.md` troubleshooting. On personal `wsl`, nixos is the
  default user and gets a manager from its own session.
- `exec zsh -l` in an already-open shell to pick up a switch; `programs.zsh.envExtra`
  lands in `~/.zshenv`, so secrets/aliases only reach zsh.
- `jq`, `sops`, `age` are in `/etc/profiles/per-user/<user>/bin`; `statix` and
  `deadnix` are not installed — `nix run nixpkgs#statix -- check .`.

## Conventions

- Formatting: `nixfmt` via `nix fmt`, also installed as a pre-commit hook in the
  shared `.git/hooks`. `nix develop` provides the repo tooling.
- Commit subjects: prefer `type(scope): summary` — `fix(wsl): ...`, `chore(home): ...`.
- Comments explain **why** (history, tradeoffs, non-obvious constraints), never
  what the code says; every module here follows that.
