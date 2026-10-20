# Hunk diff viewer configuration
{ inputs, ... }:

{
  imports = [
    inputs.hunk.homeManagerModules.default
  ];

  programs.hunk = {
    enable = true;
    enableGitIntegration = true;
    settings = {
      theme = "graphite";
      mode = "split";
      line_numbers = true;
      tab_width = 4;
    };
  };
}
