# NixOS-WSL platform settings, shared by all WSL machines.

{ ... }:

{
  wsl.enable = true;

  # No wsl.interop.register override: WSL registers the WSLInterop binfmt
  # handler itself and systemd no longer remounts binfmt_misc out from under
  # it, so .exe execution (wsl.exe, powershell.exe, wsl-open) works as-is.
  # The override was only needed on WSL 2.x (see commit aae7e62).

  # Default user is per-host (hosts/<name>/default.nix).
}
