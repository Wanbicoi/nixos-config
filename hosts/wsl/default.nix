# Host: WSL (NixOS-WSL)
#
# A host file wires together the platform modules and user profiles for one
# machine. Hardware-specific and per-machine values live here.

{ inputs, pkgs, ... }:

{
  imports = [
    inputs.nixos-wsl.nixosModules.default
    inputs.home-manager.nixosModules.home-manager

    ../../modules/nixos/common.nix
    ../../modules/nixos/wsl.nix
  ];

  networking.hostName = "nixos-wsl";

  wsl.defaultUser = "nixos";

  # Make zsh the login shell (configured via Home Manager).
  users.users.nixos.shell = pkgs.zsh;

  system.stateVersion = "26.05";

  # Home Manager: the shared user environment every NixOS host reuses.
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    backupFileExtension = "hm-backup";

    users.nixos.imports = [ ../../home/nixos ];
  };
}
