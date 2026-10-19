# Host: WSL (Laidon) — the company-first distro on the same machine.
#
# `troy` is the WSL default user, so every Windows-side entry point (Explorer's
# \\wsl.localhost, VS Code Remote-WSL, Windows Terminal, a bare `wsl.exe`)
# lands in the company persona. `nixos` remains the admin account (uid 1001,
# wheel) and is entered deliberately with `wsl.exe -u nixos`; troy has no sudo,
# so there is no `sudo -iu nixos` path from inside.
#
# This is a separate distro rather than flipping `wsl.defaultUser` on hosts/wsl:
# troy is uid 1000 from the start, which is what the drvfs automount
# (`metadata,uid=1000,gid=100`) expects, so no home-directory chown migration
# is needed. See the uid note in hosts/wsl/default.nix.
{
  inputs,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    inputs.nixos-wsl.nixosModules.default
    inputs.home-manager.nixosModules.home-manager

    ../../modules/nixos/common.nix
    ../../modules/nixos/wsl.nix
    ../../modules/nixos/llm-agents.nix
  ];

  networking.hostName = "wsl-laidon";

  system.stateVersion = "26.05";

  # `acli` (Atlassian CLI, in troy's Laidon profile) is licensed unfree. Keep
  # the exception scoped to that package instead of allowing unfree globally;
  # the wrapper and the binary it wraps each need an entry because the license
  # check runs per derivation.
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (pkgs.lib.getName pkg) [
      "acli"
      "acli-unwrapped"
    ];

  wsl.defaultUser = "troy";

  # Multi-user checkout (personal wsl is single-user and keeps it 0700): nixos
  # owns the flake checkout; company users are in the nixconfig group only to
  # read it, never to write what root later evaluates. Homes stay private;
  # cross-identity files belong in /srv/shared.
  users.groups.nixconfig = { };
  users.groups.shared = { };

  # The default ACLs are what make group write independent of the creator's
  # umask: without them a normal 022 umask would create 0644 files in the
  # setgid directory, and the other identity could not edit them. Regular
  # files still get no execute bit — the mode passed to open() masks the ACL.
  systemd.tmpfiles.rules = [
    "d /srv/shared 2775 root shared -"
    "a /srv/shared - - - - g:shared:rwx"
    "a /srv/shared - - - - d:g:shared:rwx"
    "z /srv/nixconfig 2750 nixos nixconfig - -"
  ];

  # `nixos-rebuild switch --flake .#wsl-laidon` evaluates as root, and git
  # refuses repos owned by another user. Each root needs the bare path plus the
  # `/*` glob because safe.directory is not recursive.
  programs.git = {
    enable = true;
    config.safe.directory = [
      "/srv/nixconfig"
      "/srv/nixconfig/*"
      "/srv/shared"
      "/srv/shared/*"
    ];
  };

  # NixOS-WSL already declares the default user as isNormalUser with uid 1000
  # and adds "wheel" to its extraGroups. mkForce drops wheel: the company
  # persona must not be an admin (no sudo, no trusted-user).
  #
  # linger is needed even though troy is the default user: Home Manager's
  # system unit runs *before* systemd-user-sessions.service, so the login
  # session (and therefore user@1000) does not exist yet. Without a manager,
  # HM skips the user units and sops-nix never renders troy's secrets.
  users.users.troy = {
    uid = 1000;
    extraGroups = lib.mkForce [
      "nixconfig"
      "shared"
    ];
    shell = pkgs.zsh;
    linger = true;
  };

  # Admin account. It is never a login session (entered with `wsl.exe -u
  # nixos`), so linger starts user@1001 at boot for the same reason as troy.
  # `su` cannot work here because no profile declares a password hash.
  users.users.nixos = {
    isNormalUser = true;
    uid = 1001;
    extraGroups = [
      "nixconfig"
      "shared"
      "wheel"
    ];
    shell = pkgs.zsh;
    linger = true;
  };

  # Explorer's 9p share runs as the default user (troy), so /home/troy stays
  # 0700 with no browse grant. /home/nixos is never exposed that way.

  # One Home Manager profile per user; both share modules/nixos and home/common.
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    backupFileExtension = "hm-backup";

    users.nixos.imports = [ ../../home/nixos ];
    users.troy.imports = [ ../../home/troy ];
  };
}
