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
    options = "--delete-older-than 3d";
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

  # Browsers downloaded by Playwright (`playwright-cli install-browser`) are
  # generic Ubuntu builds and need the usual desktop stack, which nix-ld does
  # not provide by default. Without these the bundled Chromium dies with
  # "libglib-2.0.so.0: cannot open shared object file". Listing them here keeps
  # Chromium out of the Nix config: Playwright owns the browser version.
  programs.nix-ld.libraries = with pkgs; [
    alsa-lib
    atk
    at-spi2-atk
    at-spi2-core
    cairo
    cups
    dbus
    expat
    glib
    libdrm
    libgbm
    libX11
    libxcb
    libXcomposite
    libXdamage
    libXext
    libXfixes
    libxkbcommon
    libXrandr
    libxshmfence
    mesa
    nspr
    nss
    pango
  ];

  # Minimal toolset available on all NixOS machines. User-level tools belong in
  # home/<user>/ instead.
  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    curl
  ];
}
