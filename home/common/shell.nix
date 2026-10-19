# Interactive shell: zsh itself and the starship prompt.
{
  config,
  lib,
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

    # The shared /srv/nixconfig checkout must stay group-writable so both users
    # can edit it; the default 022 umask would strip group write on new files.
    initContent = lib.mkAfter "umask 002";

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

      # First prompt line: user, context, then a fill that pushes the last
      # command's duration to the end of the line, then the input character.
      format = "$username$directory$git_branch$git_status$fill$cmd_duration$line_break$character";

      # Always show who you are: several users share this distro, and a plain
      # `su - troy` prompt would otherwise look identical to nixos'.
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
