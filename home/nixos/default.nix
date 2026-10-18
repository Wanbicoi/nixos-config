{ config, pkgs, ... }:

let
  # The nvim-config git submodule checked out inside this repo. Linked
  # out-of-store so lazy.nvim (or any plugin manager) can write to it.
  nvimConfig = "${config.home.homeDirectory}/nixconfig/nvim";
in
{
  home = {
    username = "nixos";
    homeDirectory = "/home/nixos";
    stateVersion = "26.05";
    sessionVariables.EDITOR = "nvim";
  };

  # Use the Lua config from the nvim-config submodule as ~/.config/nvim.
  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink nvimConfig;

  programs = {
    home-manager.enable = true;

    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      shellAliases = {
        vi = "nvim";
        vim = "nvim";
      };

      # Print a full-width rule before each prompt so command output is
      # visually separated from the next prompt.
      initExtra = ''
        _nixconfig_rule() {
          repeat ''${COLUMNS:-80} printf '─'
          printf '\n'
        }
        autoload -Uz add-zsh-hook
        add-zsh-hook precmd _nixconfig_rule
      '';
    };

    starship = {
      enable = true;
      enableZshIntegration = true;
      settings.add_newline = false;
    };

    git = {
      enable = true;
      settings.user = {
        name = "Troy Hoang";
        email = "troy.hoang@laidon.com";
      };
    };
  };

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
    ripgrep
    fd
    jq
    gh
  ];
}
