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
  lazygitConfig = "${cfg.repoRoot}/submodules/lazygit";
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

    # Lazygit: config directory from the lazygit submodule as ~/.config/lazygit.
    xdg.configFile."lazygit".source = link lazygitConfig;

    # --- Shared agent config (agent-config submodule) -------------------------

    # Pi: only the portable, user-authored subset is linked. Everything Pi
    # writes at runtime (auth.json, trust.json, models-store.json, sessions/,
    # npm/, web-search-cache/, tmp/, extensions/) is a real, per-user file in
    # ~/.pi/agent, so credentials and session history never live inside the
    # shared checkout where another persona could read them.
    #
    # The directory itself is deliberately NOT claimed by Home Manager (no
    # `home.file.".pi/agent"` entry): Pi owns it and creates the state
    # entries on first run. Claiming it would make Home Manager fight Pi over
    # files it does not manage.
    home.file.".pi/agent/AGENTS.md".source = link "${agentConfig}/AGENTS.md";
    home.file.".pi/agent/settings.json".source = link "${agentConfig}/pi/settings.json";

    # OpenCode: the whole global config dir.
    xdg.configFile."opencode".source = link "${agentConfig}/opencode";

    # Claude Code: only the user-authored subset. ~/.claude/settings.json is left
    # untouched because Orca rewrites it per machine (see
    # agent-config/claude/README.md). CLAUDE.md points at the canonical shared
    # AGENTS.md directly, avoiding a second hop through the in-repo symlink.
    home.file.".claude/CLAUDE.md".source = link "${agentConfig}/AGENTS.md";
    home.file.".claude/agents".source = link "${agentConfig}/claude/agents";
    home.file.".claude/commands".source = link "${agentConfig}/claude/commands";

    # Antigravity CLI (agy): shares global skills and AGENTS.md instructions.
    # Global customizations reside in ~/.gemini/config/.
    # home.file.".gemini/config/AGENTS.md".source = link "${agentConfig}/AGENTS.md";
    # home.file.".gemini/config/skills".source = link "${agentConfig}/skills";
    home.file.".gemini/antigravity-cli/AGENTS.md".source = link "${agentConfig}/AGENTS.md";
    home.file.".gemini/antigravity-cli/skills".source = link "${agentConfig}/skills";

    # Skills: one canonical directory in the repo, shared by every agent.
    # Pi and OpenCode read ~/.agents/skills; Claude Code reads ~/.claude/skills.
    home.file.".agents/skills".source = link "${agentConfig}/skills";
    home.file.".claude/skills".source = link "${agentConfig}/skills";
  };
}
