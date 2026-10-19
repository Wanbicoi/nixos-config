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

- `nixosConfigurations.wsl` — the only host. There is **no** `homeConfigurations`
  output and no `packages.*`; Home Manager is integrated through NixOS.
- Per-user Home Manager config lives at
  `nixosConfigurations.wsl.config.home-manager.users.<user>.home.*`
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

## Host `wsl` specifics

- `/etc` is a symlink into the store and **read-only**: hand edits
  (`git config --system ...`, files dropped in `/etc`) never persist. Change the
  module and switch, or pass an env override for a one-off
  (`GIT_CONFIG_GLOBAL=...`).
- `/srv/nixconfig` is a git checkout owned by `nixos`, shared with `troy` via
  group `nixconfig`, and flake evaluation runs as root under sudo — hence the
  `safe.directory` entries in `hosts/wsl/default.nix`. Repos under `/srv/shared`
  have the same cross-identity ownership mix.
- `troy` is never a login session of this distro (entered with `su - troy` or
  `wsl.exe -u troy`), so anything that needs a systemd *user* manager must be
  declared (`users.users.troy.linger`) — see `secrets/README.md` troubleshooting.
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
