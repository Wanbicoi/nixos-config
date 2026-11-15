# merry-laptop — first install

Bootstrap from a stock NixOS install to this flake. Written for the person
installing the machine, not for a running daily driver: once
`nixos-rebuild switch --flake .#merry-laptop` has run once, use the root
[`README.md`](../../README.md) instead.

Two repo-specific facts drive the order:

- the host imports `hardware-configuration.nix` from **this directory**, and
  until that file is tracked Git will not show it to the flake, so the build
  silently falls back to a `/dev/disk/by-label/nixos` root;
- `make switch` derives the host attribute from `hostname`, which is still
  `nixos` until the first switch, so that first switch must name the attribute
  explicitly.

Steps 4–5 can be driven by opencode; the manual commands are kept as the
ground truth and as the fallback.

## 0. Pick the installer user: `nixos`

The first user created by the installer gets uid 1000, which is what
`hosts/merry-laptop/default.nix` declares for `nixos`. Use exactly that
username.

Do **not** create `merry` in the installer: the config declares `merry` as uid
1001 and `nixos` as 1000, so an installer-created `merry` at 1000 collides.
`merry` is created by the config; her password is set after the first switch.

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

## 3. Clone and authenticate

```bash
git clone https://github.com/Wanbicoi/nixos-config ~/nixconfig
cd ~/nixconfig
opencode auth login --provider opencode --method key   # Console / Zen
```

`--recurse-submodules` is not needed for this host: `home/merry` does not
import `home/common`, so the nvim/agent/journals submodules are never
evaluated.

API-key entry is interactive; paste the key at the prompt. For a Go
subscription use `--provider opencode-go`. Verify with `opencode auth list`.

## 4. Hand the first switch to opencode

```bash
sudo -v
opencode run --dangerously-skip-permissions \
  --title "merry-laptop first switch" \
  "Execute steps 4 and 5 of hosts/merry-laptop/README.md on this machine. Copy
   /etc/nixos/hardware-configuration.nix into hosts/merry-laptop/, chown it to
   the current user, git add and commit it, then run
   'sudo -v && sudo nixos-rebuild switch --flake .#merry-laptop'. Use that exact
   generated file — never write a hardware configuration yourself. Only modify
   hosts/merry-laptop/. Stop on the first error and print it."
```

- `sudo -v` first: sudo cannot prompt inside an agent-run command. The cached
  timestamp lasts ~5 minutes, hence `sudo -v && sudo nixos-rebuild` in one
  command inside the prompt.
- `--dangerously-skip-permissions` is v1's auto-approve (v2 spells it
  `--auto`). Combined with the cached sudo it is effectively unattended root,
  so keep the prompt scoped to `hosts/merry-laptop/` and do not widen it to
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
sudo cp /etc/nixos/hardware-configuration.nix ~/nixconfig/hosts/merry-laptop/
sudo chown "$USER" ~/nixconfig/hosts/merry-laptop/hardware-configuration.nix
cd ~/nixconfig
git add hosts/merry-laptop/hardware-configuration.nix
git commit -m "feat(merry-laptop): add generated hardware configuration"
```

`git add` is required: flakes evaluate the Git tree, not the working
directory, so an untracked file is invisible and the by-label fallback stays
active.

Check the file: `fileSystems."/"`, `fileSystems."/boot"`, and the
`hardware.cpu.*.updateMicrocode` line.

```bash
sudo nixos-rebuild switch --flake .#merry-laptop
```

Not `make switch` yet — the hostname is still `nixos`. The build installs KDE
Plasma 6, Chrome, Edge, WPS and Zalo; Zalo downloads a ~180 MB AppImage, so
expect 15–30 minutes.

`/etc/nixos/*` stays behind and is no longer used once the flake takes over;
keeping it is harmless.

## 5. Passwords, then reboot

```bash
sudo passwd merry    # locked until this exists; SDDM login fails without it
sudo passwd nixos
sudo reboot
```

No password hash is stored in the repo on purpose — `/nix/store` is
world-readable.

## 6. First-login checks (as merry)

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
  `brl2320d.ppd` automatically; printing then works for merry too.
- **VPN**: System Settings → Connections → Add → Cisco AnyConnect
  (`openconnect`, not Cisco Secure Client). Test the gateway once with
  `sudo openconnect --user=… --authgroup=… vpn.company.com`; if the server
  insists on posture/host-scan or Umbrella, it cannot be replaced on NixOS.
- **Remote admin**: `sudo tailscale up` once (paste the login URL), then
  `ssh nixos@merry-laptop` from any device in the tailnet. Port 22 is closed on
  the physical interfaces on purpose, so this works on any Wi-Fi without
  exposing sshd.

## 7. opencode after the switch (admin)

The host installs just the opencode v2 binary from `llm-agents`, system-wide
(not the full agent set the WSL hosts import). `llm-agents` packages v2 as
`opencode2`, so it is exposed under the plain `opencode` name; v1 and v2 share
`~/.local/share/opencode` and must not run side by side. v2 imports the
bootstrap v1 `auth.json` on first start, so the key from step 3 normally
carries over.

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
cd ~/nixconfig
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
cd ~/nixconfig
git pull
make switch                          # hostname is merry-laptop by now
nix flake update zalo-for-linux      # Zalo releases independently of nixpkgs
```

## Troubleshooting

| Symptom | Cause |
| --- | --- |
| `error: Path 'hosts/merry-laptop' is not tracked by Git` | hardware file not `git add`ed (step 4) |
| rebuild warns about the placeholder root | hardware config missing or untracked (step 4) |
| merry can't log in at SDDM | `sudo passwd merry` not run (step 5) |
| opencode run hangs on sudo | run `sudo -v` first; the timestamp expires after ~5 minutes |
| `ssh: connect to host merry-laptop port 22: refused` from the LAN | expected: port 22 is only open on `tailscale0`, use the tailnet name/IP |
| `opencode: unrecognised flag --auto` during bootstrap | that is the v1 binary; use `--dangerously-skip-permissions` (step 4) |
| Bluetooth pairing asks for an admin password | BlueZ polkit policy; add a scoped `security.polkit` rule rather than putting merry in `wheel` |
| installer created a user other than `nixos` | `id -u`; if that user holds uid 1000, remove it before switching or swap the uids in the host |
