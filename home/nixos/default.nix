# Home Manager configuration for user `nixos` on NixOS machines.
#
# Home Manager is the cross-platform user layer, so anything that also makes
# sense on nix-darwin should live in a shared module and be imported here.

{ pkgs, ... }:

{
  home = {
    username = "nixos";
    homeDirectory = "/home/nixos";
    stateVersion = "26.05";
    sessionVariables.EDITOR = "nvim";
  };

  programs = {
    home-manager.enable = true;

    git = {
      enable = true;
      settings.user = {
        name = "Troy Hoang";
        email = "troy.hoang@laidon.com";
      };
    };
  };

  home.packages = with pkgs; [
    ripgrep
    fd
    jq
    gh
  ];
}
