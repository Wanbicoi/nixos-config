{ pkgs, ... }:
{
  programs = {
    gpu-screen-recorder.enable = true;
    thunar = {
      enable = true;
      plugins = with pkgs; [
        thunar-archive-plugin
        thunar-volman
      ];
    };
  };
  environment.systemPackages = with pkgs; [
    file-roller # The engine that actually handles the compression
  ];
}
