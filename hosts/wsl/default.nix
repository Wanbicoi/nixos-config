# Host: WSL (NixOS-WSL) — one distro, one user per identity.
#
# `nixos` is the personal profile and the WSL default user (uid 1000). Company
# profiles live on the same distro as extra users — `troy` is Laidon; when you
# join another company add one more block here. Enter a non-default user with
# `wsl.exe -d <distro> -u <user>` from Windows or `sudo -iu <user>` inside
# (`su` cannot work: it authenticates as the target user, and no profile
# declares a password hash).
#
# NixOS-WSL only auto-creates `wsl.defaultUser`; the others are declared here.
# The default user must keep uid 1000: the /mnt/c drvfs mount maps Windows
# files to uid 1000.
{ inputs, pkgs, ... }:

{
  imports = [
    inputs.nixos-wsl.nixosModules.default
    inputs.home-manager.nixosModules.home-manager

    ../../modules/nixos/common.nix
    ../../modules/nixos/wsl.nix
    ../../modules/nixos/llm-agents.nix
  ];

  networking.hostName = "nixos-wsl";

  system.stateVersion = "26.05";

  # `acli` (Atlassian CLI, in troy's Laidon profile) is licensed unfree, so
  # nixpkgs refuses to evaluate it. A predicate keeps this a deliberate
  # per-package exception instead of a blanket `allowUnfree = true`; the
  # FHS wrapper (`acli`) and the binary it wraps (`acli-unwrapped`) each need
  # an entry because the license check runs per derivation.
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (pkgs.lib.getName pkg) [
      "acli"
      "acli-unwrapped"
    ];

  wsl.defaultUser = "nixos";

  # Shared write access to /srv/nixconfig (path set in home/common/wsl.nix).
  users.groups.nixconfig = { };

  # Cross-identity workspace. Homes stay private (see homeMode below); anything
  # both users should reach lives here instead. The group is deliberately
  # separate from `nixconfig` so revoking workspace access does not also revoke
  # the ability to edit this repo.
  users.groups.shared = { };

  # `d` = create if missing, mode 2775. The setgid bit makes new files and
  # directories inherit the `shared` group, so group access does not depend on
  # each user's default primary group. Needs umask 002 (set in
  # home/common/shell.nix) to actually produce 0664/0775 files; otherwise a
  # plain 022 umask still lets the owner write but caps group write.
  systemd.tmpfiles.rules = [
    "d /srv/shared 2775 root shared -"
  ];

  # `nixos-rebuild switch --flake .#wsl` evaluates the flake as root, and git
  # refuses any repo whose owner is not the current user. The per-user
  # `safe.directory` in home/common/wsl.nix only covers the two login users,
  # so root needs the system-wide equivalent (this writes /etc/gitconfig).
  # Without it, `make switch` dies with "repository path '/srv/nixconfig' is
  # not owned by current user".
  #
  # safe.directory is not recursive, so each root needs its bare path plus the
  # `/*` glob for repos nested below it. See home/common/wsl.nix.
  programs.git = {
    enable = true;
    config.safe.directory = [
      "/srv/nixconfig"
      "/srv/nixconfig/*"
      "/srv/shared"
      "/srv/shared/*"
    ];
  };

  # `wsl.defaultUser` already makes nixos a normal user with uid 1000 and the
  # wheel group; only the shell and extra group are needed here.
  users.users.nixos = {
    shell = pkgs.zsh;
    extraGroups = [
      "nixconfig"
      "shared"
    ];
  };

  users.users.troy = {
    isNormalUser = true;
    uid = 1001;
    extraGroups = [
      "wheel"
      "nixconfig"
      "shared"
    ];
    shell = pkgs.zsh;

    # Home Manager renders sops secrets from a *user* service
    # (`systemctl --user restart sops-nix`), and its activation silently skips
    # that step when no user manager is running:
    #
    #   User systemd daemon not running. Probably executed on boot where no
    #   manual start/reload is needed.
    #
    # That assumption does not hold here. troy is never a login session of
    # this distro -- it is entered with `sudo -iu troy` or `wsl.exe -u troy`
    # from nixos -- so /run/user/1001 would never appear and ~/.config/sops-nix
    # would never be created, leaving every sops env var empty in troy's
    # shells. Linger starts user@1001 at boot, so the secrets are rendered
    # without an interactive session. (nixos is the WSL default user and gets
    # a manager from its own login session.)
    linger = true;

    # Windows Explorer reaches Linux files through \\wsl.localhost\<distro>,
    # and that 9p share runs as the *default* user (nixos), not as troy. The
    # default homeMode 0700 therefore made /home/troy show up as
    # "... is not accessible. You might not have permission ...". Both users
    # share the `users` group, so group r-x is enough to browse the home
    # directory (dotfiles like .zsh_history stay 0600).
    homeMode = "0750";
  };

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
