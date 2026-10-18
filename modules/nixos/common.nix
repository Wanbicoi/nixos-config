# NixOS system settings shared by every machine.
#
# Keep this platform-generic. Machine-specific values (hostname, default user,
# state version) belong in hosts/<name>/default.nix.

{ pkgs, ... }:

{
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];

    # Trust flake `nixConfig` (e.g. the Numtide cache in flake.nix) without
    # passing --accept-flake-config on every rebuild.
    accept-flake-config = true;

    # Let wheel users use extra substituters/build options from the CLI.
    trusted-users = [
      "root"
      "@wheel"
    ];

    # Deduplicate identical store paths: slower downloads, faster builds/links.
    auto-optimise-store = true;
  };

  # Free up space automatically.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  # Install zsh system-wide so it can be used as a login shell. The actual
  # shell configuration lives in Home Manager (home/<user>/).
  programs.zsh.enable = true;

  # Minimal toolset available on all NixOS machines. User-level tools belong in
  # home/<user>/ instead.
  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    curl
  ];
}
