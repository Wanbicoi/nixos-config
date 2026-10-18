{
  config,
  inputs,
  pkgs,
  ...
}:

let
  # Submodules checked out inside this repo. Linked out-of-store (writable
  # checkouts, not /nix/store) so their tools can write to them. Keeping the
  # Claude links out of the store also avoids a Claude Code bug where the
  # settings watcher enumerates a symlink's parent directory.
  repoRoot = "${config.home.homeDirectory}/nixconfig";
  nvimConfig = "${repoRoot}/submodules/nvim";
  agentConfig = "${repoRoot}/submodules/agent-config";
in
{
  imports = [ inputs.sops-nix.homeManagerModules.sops ];

  # Age-encrypted secrets (see .sops.yaml + secrets/). The private key lives
  # outside the repo at ~/.config/sops/age/keys.txt.
  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    defaultSopsFile = ../../secrets/common.yaml;
    secrets.example_secret = { };

    templates."shell.env" = {
      mode = "0400";
      content = ''
        export EXAMPLE_SECRET="${config.sops.placeholder.example_secret}"
      '';
    };
  };

  home = {
    username = "nixos";
    homeDirectory = "/home/nixos";
    stateVersion = "26.05";
    sessionVariables.EDITOR = "nvim";
  };

  # Use the Lua config from the nvim-config submodule as ~/.config/nvim.
  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink nvimConfig;

  # --- Shared agent config (agent-config submodule) ---------------------------
  # Pi: the whole agent dir (auth/sessions/npm are gitignored in the repo).
  home.file.".pi/agent".source = config.lib.file.mkOutOfStoreSymlink "${agentConfig}/pi";

  # OpenCode: the whole global config dir.
  xdg.configFile."opencode".source = config.lib.file.mkOutOfStoreSymlink "${agentConfig}/opencode";

  # Claude Code: only the user-authored subset. ~/.claude/settings.json is left
  # untouched because Orca rewrites it per machine (see
  # agent-config/claude/README.md).
  home.file.".claude/CLAUDE.md".source =
    config.lib.file.mkOutOfStoreSymlink "${agentConfig}/claude/CLAUDE.md";
  home.file.".claude/agents".source =
    config.lib.file.mkOutOfStoreSymlink "${agentConfig}/claude/agents";
  home.file.".claude/commands".source =
    config.lib.file.mkOutOfStoreSymlink "${agentConfig}/claude/commands";
  home.file.".claude/skills".source =
    config.lib.file.mkOutOfStoreSymlink "${agentConfig}/claude/skills";

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

      # Export sops secrets as env vars for every shell (and apps launched
      # from it). The template is generated at activation.
      envExtra = ''
        [[ -r "${config.sops.templates."shell.env".path}" ]] && source "${
          config.sops.templates."shell.env".path
        }"
      '';
    };

    starship = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        # Keep a blank line between command output and the prompt.
        add_newline = true;

        # First prompt line, then a full-width fill, then the input character.
        # Add modules here if you want more (e.g. $nodejs, $cmd_duration).
        format = "$directory$git_branch$git_status$fill$line_break$character";

        fill = {
          symbol = "─";
          style = "dimmed";
        };
      };
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
    sops
    age
    ripgrep
    fd
    jq
    gh
  ];
}
