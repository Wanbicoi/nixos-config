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

  # zoxide as a smarter `cd`: `--cmd cd` makes zoxide define `cd` (and `cdi`
  # for the fzf picker) instead of `z`/`zi`. zoxide's `cd` still behaves like
  # the builtin for real paths (`cd ..`, `cd /etc`, `cd -`), and falls back to
  # its frecency database for anything that is not an existing path.
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    options = [
      "--cmd"
      "cd"
    ];
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      # Keep a blank line between command output and the prompt.
      add_newline = true;

      # First prompt line: user, context, then a fill that pushes the last
      # command's duration to the end of the line, then the input character.
      format = "$username$directory$git_branch$git_status$fill$cmd_duration$line_break$character";

      # Always show who you are: wsl-laidon has several users, and a plain
      # prompt under `sudo -iu troy` would otherwise look identical to nixos'.
      username = {
        show_always = true;
        style_user = "bold cyan";
        style_root = "bold red";
        format = "[$user]($style) in ";
      };

      # Dashes instead of a solid rule, so the fill reads as spaced out.
      fill = {
        symbol = "-";
        style = "dimmed";
      };

      # Last command's execution time, right-aligned at the end of line one.
      cmd_duration = {
        min_time = 0;
        show_milliseconds = true;
        style = "dimmed yellow";
        format = " [$duration]($style)";
      };
    };
  };
}
