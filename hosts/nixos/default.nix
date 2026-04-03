{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system/base.nix
    ../../home/trung/services.nix
  ];

  system.stateVersion = "25.11";
}