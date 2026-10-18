# Submodules checked out inside this repo, linked into the home directory.
#
# These are linked out-of-store (writable checkouts, not /nix/store) so their
# tools can write to them. Keeping the Claude links out of the store also
# avoids a Claude Code bug where the settings watcher enumerates a symlink's
# parent directory.
{
  config,
  ...
}:

let
  repoRoot = "${config.home.homeDirectory}/nixconfig";
  nvimConfig = "${repoRoot}/submodules/nvim";
  agentConfig = "${repoRoot}/submodules/agent-config";
  link = path: config.lib.file.mkOutOfStoreSymlink path;
in
{
  # Neovim: the Lua config from the nvim submodule as ~/.config/nvim.
  xdg.configFile."nvim".source = link nvimConfig;

  # --- Shared agent config (agent-config submodule) ---------------------------

  # Pi: the whole agent dir (auth/sessions/npm are gitignored in the repo).
  home.file.".pi/agent".source = link "${agentConfig}/pi";

  # OpenCode: the whole global config dir.
  xdg.configFile."opencode".source = link "${agentConfig}/opencode";

  # Claude Code: only the user-authored subset. ~/.claude/settings.json is left
  # untouched because Orca rewrites it per machine (see
  # agent-config/claude/README.md).
  home.file.".claude/CLAUDE.md".source = link "${agentConfig}/claude/CLAUDE.md";
  home.file.".claude/agents".source = link "${agentConfig}/claude/agents";
  home.file.".claude/commands".source = link "${agentConfig}/claude/commands";
  home.file.".claude/skills".source = link "${agentConfig}/claude/skills";
}
