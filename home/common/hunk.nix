# Hunk diff viewer configuration
{ inputs, ... }:

{
  imports = [
    inputs.hunk.homeManagerModules.default
  ];

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
