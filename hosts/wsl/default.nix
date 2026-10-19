# Host: WSL (NixOS-WSL) — one distro, one user per identity.
#
# `nixos` is the personal profile and the WSL default user (uid 1000). Company
# profiles live on the same distro as extra users — `troy` is Laidon; when you
# join another company add one more block here. Enter a non-default user with
# `wsl.exe -d <distro> -u <user>` from Windows or `su - <user>` inside.
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

  wsl.defaultUser = "nixos";

  # Shared write access to /srv/nixconfig (path set in home/common/wsl.nix).
  users.groups.nixconfig = { };

  # `wsl.defaultUser` already makes nixos a normal user with uid 1000 and the
  # wheel group; only the shell and extra group are needed here.
  users.users.nixos = {
    shell = pkgs.zsh;
    extraGroups = [ "nixconfig" ];
  };

  users.users.troy = {
    isNormalUser = true;
    uid = 1001;
    extraGroups = [
      "wheel"
      "nixconfig"
    ];
    shell = pkgs.zsh;

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
