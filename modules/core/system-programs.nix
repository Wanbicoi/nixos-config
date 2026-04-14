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

    nix-ld.enable = true;
    nix-ld.libraries = with pkgs; [
      # Minimal runtime deps for the inspected C# Dev Kit server binary
      stdenv.cc.cc
      glibc
    ];
  };
  environment.systemPackages = with pkgs; [
    file-roller # The engine that actually handles the compression
  ];
}
