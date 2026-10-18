# Host: Laidon WSL (NixOS-WSL)
#
# Same platform modules as `wsl`, but a different user (`troy`) and an extra
# Laidon toolset. See home/troy/packages.nix.

{ inputs, pkgs, ... }:

{
  imports = [
    inputs.nixos-wsl.nixosModules.default
    inputs.home-manager.nixosModules.home-manager

    ../../modules/nixos/common.nix
    ../../modules/nixos/wsl.nix
    ../../modules/nixos/llm-agents.nix
  ];

  networking.hostName = "nixos-wsl-laidon";

  wsl.defaultUser = "troy";

  # Make zsh the login shell (configured via Home Manager).
  users.users.troy.shell = pkgs.zsh;

  system.stateVersion = "26.05";

  # Home Manager: the shared user environment plus troy's Laidon packages.
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    backupFileExtension = "hm-backup";

    users.troy.imports = [ ../../home/troy ];
  };
}
