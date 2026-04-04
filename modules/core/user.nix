{
  pkgs,
  inputs,
  ...
}:
{
  # environment.pathsToLink = [
  #   "/share/applications"
  #   "/share/xdg-desktop-portal"
  # ];

  programs.zsh.enable = true;

  imports = [ inputs.home-manager.nixosModules.home-manager ];
  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    users.trung = {
      imports = [ ./../desktop/kde ];
      home.username = "trung";
      home.homeDirectory = "/home/trung";
      home.stateVersion = "25.11";
      programs.home-manager.enable = true;
    };
    # TODO: Research for this later
    # backupFileExtension = "hm-backup";
  };

  users.users.trung = {
    isNormalUser = true;
    description = "Trung Hoang";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.zsh;
  };
  # TODO: Research for this later
  # nix.settings.allowed-users = [ "trung" ];
}
