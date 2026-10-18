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

  # Run unpatched prebuilt binaries (e.g. tools installed by Mason/npm/pip)
  # that hardcode the generic /lib64/ld-linux-x86-64.so.2 loader. NixOS points
  # that path at a stub that refuses to run; this replaces it with nix-ld, which
  # forwards to the Nix glibc loader plus the default library set. Necessary for
  # Mason's lua-language-server and similar prebuilt LSPs.
  programs.nix-ld.enable = true;

  # Minimal toolset available on all NixOS machines. User-level tools belong in
  # home/<user>/ instead.
  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    curl
  ];
}
