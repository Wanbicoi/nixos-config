# User-level packages for every machine.
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    neovim
    tree-sitter
    lazygit
    python3
    pnpm
    nodejs
    cargo
    rustc
    gcc
    gnumake
    sops
    age
    ripgrep
    fd
    jq
    gh
  ];
}
