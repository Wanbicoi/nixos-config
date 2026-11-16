# NixOS-WSL platform settings, shared by all WSL machines.

{ ... }:

{
  wsl.enable = true;

  # Tailnet access from inside the distro. The peer these hosts need is
  # meri-laptop, whose sshd listens on tailscale0 only (see
  # hosts/meri-laptop), so SSH to it over the LAN is filtered by design.
  #
  # WSL exposes a real /dev/net/tun, so tailscaled runs in normal TUN mode.
  # Log in once with `sudo tailscale up --accept-dns=false`; the flag is stored
  # in the node prefs and survives reboots. DNS stays untouched on purpose:
  # /etc/resolv.conf points at the Windows resolver (search domain `fpt`), and
  # the peer is reachable by its 100.x address, so MagicDNS is not needed.
  services.tailscale.enable = true;

  # No wsl.interop.register override: WSL registers the WSLInterop binfmt
  # handler itself and systemd no longer remounts binfmt_misc out from under
  # it, so .exe execution (wsl.exe, powershell.exe, wsl-open) works as-is.
  # The override was only needed on WSL 2.x (see commit aae7e62).

  # Default user is per-host (hosts/<name>/default.nix).
}
