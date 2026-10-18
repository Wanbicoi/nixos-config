# Submodules checked out inside this repo, linked into the home directory.
#
# These are linked out-of-store (writable checkouts, not /nix/store) so their
# tools can write to them. Keeping the Claude links out of the store also
# avoids a Claude Code bug where the settings watcher enumerates a symlink's
# parent directory.
{
  config,
  lib,
  ...
}:

let
  cfg = config.submodules;

  nvimConfig = "${cfg.repoRoot}/submodules/nvim";
  agentConfig = "${cfg.repoRoot}/submodules/agent-config";
  link = path: config.lib.file.mkOutOfStoreSymlink path;
in
{
  options.submodules.repoRoot = lib.mkOption {
    type = lib.types.str;
    default = "${config.home.homeDirectory}/nixconfig";
    description = ''
      Path to the nixconfig checkout whose submodules are linked into $HOME.
      Override in home/<user>/identity.nix when several users share one
      checkout instead of keeping a copy in each home.
    '';
  };

  config = {
    # Neovim: the Lua config from the nvim submodule as ~/.config/nvim.
    xdg.configFile."nvim".source = link nvimConfig;

    # --- Shared agent config (agent-config submodule) -------------------------

    # Pi: the whole agent dir (auth/sessions/npm are gitignored in the repo).
    home.file.".pi/agent".source = link "${agentConfig}/pi";

    # OpenCode: the whole global config dir.
    xdg.configFile."opencode".source = link "${agentConfig}/opencode";

    # Claude Code: only the user-authored subset. ~/.claude/settings.json is left
    # untouched because Orca rewrites it per machine (see
    # agent-config/claude/README.md). CLAUDE.md points at the canonical shared
    # AGENTS.md directly, avoiding a second hop through the in-repo symlink.
    home.file.".claude/CLAUDE.md".source = link "${agentConfig}/AGENTS.md";
    home.file.".claude/agents".source = link "${agentConfig}/claude/agents";
    home.file.".claude/commands".source = link "${agentConfig}/claude/commands";
    # Skills: one canonical directory in the repo, shared by every agent.
    # Pi and OpenCode read ~/.agents/skills; Claude Code reads ~/.claude/skills.
    home.file.".agents/skills".source = link "${agentConfig}/skills";
    home.file.".claude/skills".source = link "${agentConfig}/skills";
  };
}
