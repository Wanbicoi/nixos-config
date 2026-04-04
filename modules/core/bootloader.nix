{ pkgs, ... }:
{
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      # TODO: Research for this later
      systemd-boot.configurationLimit = 10;
    };
    # TODO: Research for this later
    # kernelPackages = pkgs.linuxPackages_latest;
    # kernelModules = [ "hid-nintendo" ];
    # supportedFilesystems = [ "ntfs" ];
  };
}
