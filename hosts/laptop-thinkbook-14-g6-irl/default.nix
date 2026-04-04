{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./../../modules/core
  ];
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
    ];
  };
}