{ ... }:
{
  programs.starship.enable = true;
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;
  };
  programs.alacritty = {
    enable = true;
    theme = "github_light_colorblind";
    settings = {
      font.normal.family = "Maple Mono NF";
      window.padding.x = 8;
      window.padding.y = 8;
    };
  };
}
