# Hunk diff viewer configuration
{
  config,
  inputs,
  ...
}:

let
  # Derive an isolated daemon port per user to prevent collision on loopback (127.0.0.1).
  # troy (default user) uses default 47657; nixos uses 47658.
  hunkPort = if config.home.username == "nixos" then "47658" else "47657";
in
{
  imports = [
    inputs.hunk.homeManagerModules.default
  ];

  # Export HUNK_MCP_PORT into the user's environment for shell sessions and herdr child processes.
  home.sessionVariables = {
    HUNK_MCP_PORT = hunkPort;
  };

  programs.hunk = {
    enable = true;
    enableGitIntegration = false;
    settings = {
      theme = "slack-ochin";
      mode = "split";
      line_numbers = true;
      tab_width = 4;
      sidebar = true;
    };
  };
}
