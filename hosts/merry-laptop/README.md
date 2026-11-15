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

## 2. Enable flakes once

In `/etc/nixos/configuration.nix`, inside the top-level block:

```nix
nix.settings.experimental-features = [ "nix-command" "flakes" ];
environment.systemPackages = with pkgs; [ git ];
```

```bash
sudo nixos-rebuild switch
```

## 3. Clone the checkout

```bash
git clone https://github.com/Wanbicoi/nixos-config ~/nixconfig
cd ~/nixconfig
```

`--recurse-submodules` is not needed for this host: `home/merry` does not
import `home/common`, so the nvim/agent/journals submodules are never
evaluated.

## 4. Move the generated hardware config in

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

## 5. First switch

```bash
cd ~/nixconfig
sudo nixos-rebuild switch --flake .#merry-laptop
```

Not `make switch` yet — the hostname is still `nixos`. The build installs KDE
Plasma 6, Chrome, Edge, WPS and Zalo; Zalo downloads a ~180 MB AppImage, so
expect 15–30 minutes.

`/etc/nixos/*` stays behind and is no longer used once the flake takes over;
keeping it is harmless.

## 6. Passwords, then reboot

```bash
sudo passwd merry    # locked until this exists; SDDM login fails without it
sudo passwd nixos
sudo reboot
```

No password hash is stored in the repo on purpose — `/nix/store` is
world-readable.

## 7. First-login checks (as merry)

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

## 8. opencode (admin)

The host installs just the opencode v2 binary from `llm-agents`, system-wide
(not the full agent set the WSL hosts import). `llm-agents` packages v2 as
`opencode2`, so it is exposed under the plain `opencode` name; v1 and v2 share
`~/.local/share/opencode` and must not run side by side.

Credentials are **per user** and stored in opencode's SQLite database, never in
this repo.

```bash
opencode --version                              # v2, prebuilt from the Numtide cache
opencode auth login opencode --method key       # Console / Zen (pay-as-you-go)
# or, for a Go subscription:
opencode auth login opencode-go --method key
opencode auth list
```

API-key entry is interactive on purpose: v2 has no `--api-key` flag, so paste
the key at the prompt. Then either open the TUI (`opencode`) or let it work
non-interactively:

```bash
cd ~/nixconfig
opencode run "Check this host with nix flake check and list what is still
missing before the first boot"
```

If `run` reports no model, select one in the TUI (`/models`) or pass it
explicitly with `--model opencode/<model-id>` (`opencode models` lists them).

Useful afterwards: `opencode debug paths db` (where the credentials live),
`opencode auth logout` (remove an account), and
`opencode auth export`/`import` to move credentials between machines — that
file contains secrets, treat it like a private key.

## 9. Updates

```bash
cd ~/nixconfig
git pull
make switch                          # hostname is merry-laptop by now
nix flake update zalo-for-linux      # Zalo releases independently of nixpkgs
```

## Troubleshooting

| Symptom | Cause |
| --- | --- |
| `error: Path 'hosts/merry-laptop' is not tracked by Git` | step 4 `git add` skipped |
| rebuild warns about the placeholder root | hardware config missing or untracked (step 4) |
| merry can't log in at SDDM | `sudo passwd merry` not run (step 6) |
| Bluetooth pairing asks for an admin password | BlueZ polkit policy; add a scoped `security.polkit` rule rather than putting merry in `wheel` |
| installer created a user other than `nixos` | `id -u`; if that user holds uid 1000, remove it before switching or swap the uids in the host |
