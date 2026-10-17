# NixOS system settings shared by every machine.
#
# Keep this platform-generic. Machine-specific values (hostname, default user,
# state version) belong in hosts/<name>/default.nix.

{ pkgs, ... }:

{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Free up space automatically.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  # Minimal toolset available on all NixOS machines. User-level tools belong in
  # home/<user>/ instead.
  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    curl
  ];
}
