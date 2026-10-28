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
    defaultKeymap = "viins";
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

    initContent = ''
      # Allow Backspace to delete past the Insert-mode entry point
      bindkey -M viins '^?' backward-delete-char
      bindkey -M viins '^H' backward-delete-char

      # Allow Ctrl+W to delete the previous word without that restriction
      bindkey -M viins '^W' backward-kill-word

      # Vi-mode clipboard integration: sync yanked text to the system clipboard
      # via OSC 52 (matching Neovim), with fallback to system clipboard bridges.
      function _vi_yank_to_clipboard() {
        local data="$CUTBUFFER"
        [[ -z "$data" ]] && return 0

        # Primary: OSC 52 escape sequence for terminal emulators (WezTerm,
        # Alacritty, Windows Terminal, SSH, etc.), including tmux passthrough.
        local b64 osc52
        b64="$(print -rn -- "$data" | base64 | tr -d '\r\n')"
        osc52="\e]52;c;$b64\a"

        if [[ -n "$TMUX" ]]; then
          osc52="\ePtmux;\e$osc52\e\\"
        elif [[ "$TERM" == screen* ]]; then
          osc52="\eP$osc52\e\\"
        fi

        if [[ -w /dev/tty ]]; then
          print -n -- "$osc52" > /dev/tty
        elif [[ -t 2 ]]; then
          print -n -- "$osc52" >&2
        fi

        # Fallback for environments where the terminal does not accept OSC 52:
        if (( $+commands[clip.exe] )); then
          ( print -rn -- "$data" | clip.exe 2>/dev/null ) &!
        elif [[ -n "$WAYLAND_DISPLAY" ]] && (( $+commands[wl-copy] )); then
          ( print -rn -- "$data" | wl-copy 2>/dev/null ) &!
        elif (( $+commands[pbcopy] )); then
          ( print -rn -- "$data" | pbcopy 2>/dev/null ) &!
        elif [[ -n "$DISPLAY" ]] && (( $+commands[xclip] )); then
          ( print -rn -- "$data" | xclip -selection clipboard 2>/dev/null ) &!
        elif [[ -n "$DISPLAY" ]] && (( $+commands[xsel] )); then
          ( print -rn -- "$data" | xsel --clipboard --input 2>/dev/null ) &!
        fi
      }

      function vi-yank-clip() {
        zle .vi-yank
        _vi_yank_to_clipboard
      }
      zle -N vi-yank vi-yank-clip

      function vi-yank-whole-line-clip() {
        zle .vi-yank-whole-line
        _vi_yank_to_clipboard
      }
      zle -N vi-yank-whole-line vi-yank-whole-line-clip

      function vi-yank-eol-clip() {
        zle .vi-yank-eol
        _vi_yank_to_clipboard
      }
      zle -N vi-yank-eol vi-yank-eol-clip

      # Bind yank in normal (vicmd) and visual modes:
      # - 'y' + motion (e.g. yw, y$) yanks motion
      # - 'Y' yanks from cursor to end of line (consistent with D and C)
      # - 'yy' yanks the entire line
      bindkey -M vicmd "y" vi-yank
      bindkey -M vicmd "Y" vi-yank-eol
      bindkey -M vicmd "yy" vi-yank-whole-line
      bindkey -M visual "y" vi-yank
      bindkey -M visual "Y" vi-yank-whole-line
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

  # Claude Code runs each command in a shell rebuilt from a snapshot that drops
  # zoxide's chpwd hook, so zoxide's self-check warns on every `cd`. The hook
  # is intact in real terminals; silence the check.
  home.sessionVariables._ZO_DOCTOR = "0";

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
