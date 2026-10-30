# Host: WSL (personal) — the personal distro, with `nixos` as the only account.
#
# Company personas live on hosts/wsl-laidon, a separate distro, so this host
# needs none of the cross-identity groups, the shared workspace, or the company
# unfree exceptions.
#
# `nixos` is the WSL default user (uid 1000); the /mnt/c drvfs mount maps
# Windows files to uid 1000, so that stays fixed.
{ inputs, pkgs, ... }:

{
  imports = [
    inputs.nixos-wsl.nixosModules.default
    inputs.home-manager.nixosModules.home-manager

    ../../modules/nixos/common.nix
    ../../modules/nixos/wsl.nix
    ../../modules/nixos/llm-agents.nix
    ../../modules/nixos/herdr.nix
    ../../modules/nixos/journals.nix
  ];

  networking.hostName = "nixos-wsl";

  system.stateVersion = "26.05";

  wsl.defaultUser = "nixos";

  # The checkout lives outside the home (submodules.repoRoot in
  # home/common/wsl.nix) and root re-evaluates it on every rebuild. Only nixos
  # may write it; the journals system user reads it through the nixconfig
  # group (see modules/nixos/journals.nix).
  systemd.tmpfiles.rules = [
    "z /srv/nixconfig 2750 nixos nixconfig - -"
  ];

  # Both hosts use 4321; run at most one journals service at a time if the
  # distros share a network namespace.
  services.journals.enable = true;
  services.journals.port = 4321;

  # `nixos-rebuild switch --flake .#wsl` evaluates the flake as root, and git
  # refuses any repo whose owner is not the current user. The per-user
  # `safe.directory` in home/common/wsl.nix only covers the login user, so root
  # needs the system-wide equivalent (this writes /etc/gitconfig). Without it,
  # `make switch` dies with "repository path '/srv/nixconfig' is not owned by
  # current user". safe.directory is not recursive, hence the `/*` glob.
  programs.git = {
    enable = true;
    config.safe.directory = [
      "/srv/nixconfig"
      "/srv/nixconfig/*"
    ];
  };

  # `wsl.defaultUser` already makes nixos a normal user with uid 1000 and the
  # wheel group; only the shell is needed here.
  users.users.nixos = {
    shell = pkgs.zsh;
  };

  # One Home Manager profile; company profiles are imported by wsl-laidon.
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    backupFileExtension = "hm-backup";

    users.nixos.imports = [ ../../home/nixos ];
  };
}
