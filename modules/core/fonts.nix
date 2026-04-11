{ pkgs, ... }:
{
  fonts = {
    fontconfig = {
      enable = true;
      antialias = true;
      hinting = {
        enable = true;
        style = "slight"; # 'slight' is usually closest to Windows; 'full' can look blocky
      };
      defaultFonts = {
        monospace = [
          "Maple Mono NF"
          "Cascadia Code NF"
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
