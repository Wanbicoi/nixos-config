# Interactive shell: zsh itself and the starship prompt.
{
  config,
  ...
}:

{
  programs.zsh = {
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

  programs.starship = {
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
}
