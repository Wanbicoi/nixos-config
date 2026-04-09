{ pkgs, ... }:
{
  fonts = {
    fontconfig = {
      enable = true;

      defaultFonts = {
        monospace = [
          "Cascadia Code NF"
          "Maple Mono NF"
          "JetBrainsMono Nerd Font"
        ];
        sansSerif = [ "Public Sans" ];
        serif = [ "Noto Serif" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };

    packages = with pkgs; [
      noto-fonts
      public-sans
      maple-mono.NF

      cascadia-code
      nerd-fonts.jetbrains-mono
      nerd-fonts.symbols-only

      # twemoji-color-font
      noto-fonts-color-emoji
    ];
  };
}
