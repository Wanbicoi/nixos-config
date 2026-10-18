# NixOS-WSL platform settings, shared by all WSL machines.

{ ... }:

{
  wsl.enable = true;

  # Re-register the binfmt_misc handler for Windows executables. WSL's own
  # /init sets it up at boot, but NixOS's systemd remounts binfmt_misc and the
  # registration is lost, so every .exe (wsl.exe, powershell.exe, ...) fails
  # with "Exec format error". nixos-wsl defaults this to false on the
  # assumption the registration survives; it does not here.
  wsl.interop.register = true;

  # Default user is per-host (hosts/<name>/default.nix).
}
