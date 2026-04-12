{ ... }:
{
  boot = {
    # for some reason, the default is "suspend" and not "deep". This make the system to sleep
    kernelParams = [ "mem_sleep_default=deep" ];

    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      timeout = 0;
      systemd-boot.configurationLimit = 10;
    };
    # TODO: Research for this later
    # kernelPackages = pkgs.linuxPackages_latest;
    # kernelModules = [ "hid-nintendo" ];
    # supportedFilesystems = [ "ntfs" ];
  };
}
