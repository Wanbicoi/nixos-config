# meri-laptop — first install

Bootstrap from a stock NixOS install to this flake. Written for the person
installing the machine, not for a running daily driver: once
`nixos-rebuild switch --flake .#meri-laptop` has run once, use the root
[`README.md`](../../README.md) instead.

Two repo-specific facts drive the order:

- the host imports `hardware-configuration.nix` from **this directory**, and
  until that file is tracked Git will not show it to the flake, so the build
  silently falls back to a `/dev/disk/by-label/nixos` root;
- `make switch` derives the host attribute from `hostname`, which is still
  `nixos` until the first switch, so that first switch must name the attribute
  explicitly;
- the `nixos` account now runs the same profile as the WSL distros, so the
  checkout must be at `/srv/nixconfig` with its submodules and a personal sops
  key in place **before** the first switch (step 3), or `home-manager-nixos`
  fails and aborts the rebuild.

Steps 4–5 can be driven by opencode; the manual commands are kept as the
ground truth and as the fallback.

**Already running this flake?** Skip to step 3 for the checkout/key preparation
and then `git pull && make switch` — the rest of the guide is for a stock
install.

## 0. Pick the installer user: `nixos`

The first user created by the installer gets uid 1000, which is what
`hosts/meri-laptop/default.nix` declares for `nixos`. Use exactly that
username.

Do **not** create `meri` in the installer: the config declares `meri` as uid
1001 and `nixos` as 1000, so an installer-created `meri` at 1000 collides.
`meri` is created by the config; her password is set after the first switch.

## 1. Install NixOS

Graphical installer, default partitioning (ext4 root, swapfile, EFI `/boot`).
It writes `/etc/nixos/configuration.nix` and
`/etc/nixos/hardware-configuration.nix`, and creates `nixos` with a password.

Log in as `nixos` after the reboot.

## 2. Enable flakes, git and a bootstrap opencode

In `/etc/nixos/configuration.nix`, inside the top-level block:

```nix
nix.settings.experimental-features = [ "nix-command" "flakes" ];
environment.systemPackages = with pkgs; [ git opencode ];
```

```bash
sudo nixos-rebuild switch
```

This is a bootstrap only: `/etc/nixos` is discarded once the flake takes over,
and the host then installs opencode **v2** itself (step 7). The nixpkgs
`opencode` here is **v1**; its command flags differ from v2, see step 7.

## 3. Clone, then prepare the shared checkout

The `nixos` account runs the same Home Manager profile as the WSL distros, so
the checkout lives at `/srv/nixconfig` there too: the profile links the
nvim/agent submodules out of it, and the journals daemon reads it as a system
user through the `nixconfig` group.

```bash
git clone --recurse-submodules https://github.com/Wanbicoi/nixos-config ~/nixconfig
sudo mv ~/nixconfig /srv/nixconfig
sudo chown -R nixos:nixos /srv/nixconfig   # the nixconfig group exists after the first switch
cd /srv/nixconfig
# bun is not installed until the first switch, so borrow it from nixpkgs.
nix shell nixpkgs#bun -c make journals-deps

# Personal sops key: the same age key as the WSL distro, restored from backup.
# Without it home-manager-nixos fails during activation and aborts the switch.
install -d -m 700 ~/.config/sops/age
cp /path/to/keys.txt ~/.config/sops/age/keys.txt
chmod 400 ~/.config/sops/age/keys.txt
```

`--recurse-submodules` is required now: `home/nixos` imports `home/common`,
which links `submodules/nvim`, `submodules/agent-config` and
`submodules/lazygit` into `~/.config`, and `submodules/journals` is the
daemon's source tree. `make journals-deps` must also run before the first
switch, or the `journals` unit fails its `ExecStartPre` (the switch still
succeeds; journals stays down until the deps exist).

Then authenticate the bootstrap opencode (v1; the v2 installed by the switch
imports its `auth.json` on first start):

```bash
cd /srv/nixconfig
opencode auth login --provider opencode --method key   # Console / Zen
```

API-key entry is interactive; paste the key at the prompt. For a Go
subscription use `--provider opencode-go`. Verify with `opencode auth list`.

## 4. Hand the first switch to opencode

```bash
sudo -v
opencode run --dangerously-skip-permissions \
  --title "meri-laptop first switch" \
  "Execute steps 4 and 5 of hosts/meri-laptop/README.md on this machine. Copy
   /etc/nixos/hardware-configuration.nix into hosts/meri-laptop/, chown it to
   the current user, git add and commit it, then run
   'sudo -v && sudo nixos-rebuild switch --flake /srv/nixconfig#meri-laptop'.
   Use that exact generated file — never write a hardware configuration
   yourself. Only modify hosts/meri-laptop/. Stop on the first error and print
   it."
```

- `sudo -v` first: sudo cannot prompt inside an agent-run command. The cached
  timestamp lasts ~5 minutes, hence `sudo -v && sudo nixos-rebuild` in one
  command inside the prompt.
- `--dangerously-skip-permissions` is v1's auto-approve (v2 spells it
  `--auto`). Combined with the cached sudo it is effectively unattended root,
  so keep the prompt scoped to `hosts/meri-laptop/` and do not widen it to
  "fix whatever is needed".
- It cannot do step 5 or the GUI parts of step 6: `passwd` prompts, the printer
  queue, fcitx5 setup and the SDDM login need a human.
- If it reports no model, run `opencode models` and add
  `-m <provider>/<model>`.

Keep the transcript if the build fails:

```bash
opencode run ... 2>&1 | tee /tmp/bootstrap.log
echo $?                    # non-zero = it stopped
git log --oneline -2       # did it commit the hardware file?
```

### Manual equivalent

```bash
sudo cp /etc/nixos/hardware-configuration.nix /srv/nixconfig/hosts/meri-laptop/
sudo chown "$USER" /srv/nixconfig/hosts/meri-laptop/hardware-configuration.nix
cd /srv/nixconfig
git add hosts/meri-laptop/hardware-configuration.nix
git commit -m "feat(meri-laptop): add generated hardware configuration"
```

`git add` is required: flakes evaluate the Git tree, not the working
directory, so an untracked file is invisible and the by-label fallback stays
active.

Check the file: `fileSystems."/"`, `fileSystems."/boot"`, and the
`hardware.cpu.*.updateMicrocode` line.

```bash
sudo nixos-rebuild switch --flake /srv/nixconfig#meri-laptop
```

If evaluation stops with `repository path '/srv/nixconfig' is not owned by
current user`, the system-wide git config from the new host config does not
exist yet on this first run. On the laptop `/etc` is writable (unlike WSL), so
run it once and retry:

```bash
sudo git config --system --add safe.directory /srv/nixconfig
```

Not `make switch` yet — the hostname is still `nixos`. The build installs KDE
Plasma 6, Chrome, Edge, WPS, Zalo and the `nixos` developer profile; Zalo
downloads a ~180 MB AppImage, so expect 15–30 minutes.

`/etc/nixos/*` stays behind and is no longer used once the flake takes over;
keeping it is harmless.

## 5. Passwords, then reboot

```bash
sudo passwd meri    # locked until this exists; SDDM login fails without it
sudo passwd nixos
sudo reboot
```

No password hash is stored in the repo on purpose — `/nix/store` is
world-readable.

## 6. First-login checks (as meri)

- **Session**: Plasma (Wayland). `services.displayManager.defaultSession =
  "plasma"`; the X11 session is the fallback.
- **Vietnamese input**: `fcitx5-configtool` → Input Method → add **Bamboo**,
  toggle with `Ctrl+Space`.
- **Browsers**: Chrome and Edge in the app menu; Chrome handles `http(s)`.
- **WPS**: first launch shows the EULA; open a `.docx` to confirm fonts.
- **Zalo**: unofficial repack of the official macOS client (VNG ships no Linux
  build); log in by scanning the QR code.
- **Printer (Brother HL-L2320D)**: add the queue from an **nixos** session —
  NixOS lets only `wheel` edit CUPS queues. CUPS matches the USB device to
  `brl2320d.ppd` automatically; printing then works for meri too.
- **VPN**: System Settings → Connections → Add → Cisco AnyConnect
  (`openconnect`, not Cisco Secure Client). Test the gateway once with
  `sudo openconnect --user=… --authgroup=… vpn.company.com`; if the server
  insists on posture/host-scan or Umbrella, it cannot be replaced on NixOS.
- **Remote admin**: `sudo tailscale up` once (paste the login URL), then
  `ssh nixos@meri-laptop` from any device in the tailnet. Port 22 is closed on
  the physical interfaces on purpose, so this works on any Wi-Fi without
  exposing sshd.

### The nixos account (developer profile)

- **Home Manager**: `systemctl status home-manager-nixos` → active (exited).
- **Secrets**: `systemctl --user status sops-nix` → active, then
  `ls ~/.config/sops-nix/secrets/` and in a fresh zsh
  `zsh -c 'printf "%s\n" "${EXAMPLE_SECRET:+set}"'`. `linger` is enabled, so
  the render happens at boot rather than only after the first login.
- **Dotfiles**: `~/.config/nvim`, `~/.config/lazygit` and `~/.config/opencode`
  are out-of-store symlinks into `/srv/nixconfig/submodules/`.
- **Tools**: `nvim`, `lazygit`, `journals`, `herdr`, `opencode --version` (v2)
  and `claude --version` all resolve.
- **Agent auth is per user**: log in again for `opencode`, `claude` and `gh` on
  this machine; credentials from the WSL distro are not shared.

## 7. opencode after the switch (admin)

The host imports `modules/nixos/llm-agents.nix` and `modules/nixos/herdr.nix`,
so the `nixos` account gets the same system-wide agent toolset as the WSL
hosts: `opencode` v2, `claude`, `pi`, `antigravity-cli` and `herdr`.
`llm-agents` packages v2 as `opencode2`, so the module exposes it under the
plain `opencode` name; v1 and v2 share `~/.local/share/opencode` and must not
run side by side. v2 imports the bootstrap v1 `auth.json` on first start, so
the key from step 3 normally carries over.

Credentials are **per user** and stored in opencode's SQLite database, never in
this repo.

```bash
opencode --version                              # v2, prebuilt from the Numtide cache
opencode auth login opencode --method key       # Console / Zen (pay-as-you-go)
# or, for a Go subscription:
opencode auth login opencode-go --method key
opencode auth list
```

Note the v1 → v2 syntax change: v1 used `--provider`/`--method`, v2 takes the
provider as a positional argument. For `run`, v1's
`--dangerously-skip-permissions` is v2's `--auto`. Then either open the TUI
(`opencode`) or let it work non-interactively:

```bash
cd /srv/nixconfig
opencode run --auto "Check this host with nix flake check and list what is
still missing"
```

If `run` reports no model, select one in the TUI (`/models`) or pass it
explicitly with `--model opencode/<model-id>` (`opencode models` lists them).

Useful afterwards: `opencode debug paths db` (where the credentials live),
`opencode auth logout` (remove an account), and
`opencode auth export`/`import` to move credentials between machines — that
file contains secrets, treat it like a private key.

## 8. Updates

```bash
cd /srv/nixconfig
git pull
make switch                          # hostname is meri-laptop by now
nix flake update zalo-for-linux      # Zalo releases independently of nixpkgs
```

## Troubleshooting

| Symptom | Cause |
| --- | --- |
| `error: Path 'hosts/meri-laptop' is not tracked by Git` | hardware file not `git add`ed (step 4) |
| rebuild warns about the placeholder root | hardware config missing or untracked (step 4) |
| `repository path '/srv/nixconfig' is not owned by current user` | first switch happens before the host's system-wide `safe.directory` exists; `sudo git config --system --add safe.directory /srv/nixconfig` (step 4) |
| switch aborts in `home-manager-nixos` with a sops/age error | the personal `~/.config/sops/age/keys.txt` is missing (step 3) |
| `journals` unit fails in `journals-preflight` | `make journals-deps` not run in `/srv/nixconfig` (step 3) |
| `nixos` has no secrets or `~/.config/nvim` | `home-manager-nixos` did not run; `systemctl status home-manager-nixos`, then `sudo systemctl restart home-manager-nixos` |
| meri can't log in at SDDM | `sudo passwd meri` not run (step 5) |
| opencode run hangs on sudo | run `sudo -v` first; the timestamp expires after ~5 minutes |
| `ssh: connect to host meri-laptop port 22: refused` from the LAN | expected: port 22 is only open on `tailscale0`, use the tailnet name/IP |
| `opencode: unrecognised flag --auto` during bootstrap | that is the v1 binary; use `--dangerously-skip-permissions` (step 4) |
| Bluetooth pairing asks for an admin password | BlueZ polkit policy; add a scoped `security.polkit` rule rather than putting meri in `wheel` |
| installer created a user other than `nixos` | `id -u`; if that user holds uid 1000, remove it before switching or swap the uids in the host |
