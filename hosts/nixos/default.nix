{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system/base.nix
  ];

  system.stateVersion = "25.11";
}