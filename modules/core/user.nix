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
    extraSpecialArgs = { inherit inputs; };
    users.trung = {
      # imports = [ ./../desktop/kde ];
      imports = [ ./../desktop/hyprland ];
      home.username = "trung";
      home.homeDirectory = "/home/trung";
      home.stateVersion = "25.11";
      programs.home-manager.enable = true;
    };
    # when nix generates a backup of the old configuration, it will use this extension
    backupFileExtension = "hm-backup-20260406";
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
