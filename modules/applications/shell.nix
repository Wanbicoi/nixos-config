{ ... }:
{
  programs.starship.enable = true;
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;
  };

  programs.kitty = {
    enable = true;
    font.name = "Maple Mono";
    theme = "GitHub Light Colorblind";
    settings = {
      confirm_os_window_close = 0;
      window_padding_width = 8;
    };
  };
}
