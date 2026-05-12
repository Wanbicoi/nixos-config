{ pkgs, inputs, ... }:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.nixos-wsl.nixosModules.default
    ../../modules/core/system.nix
  ];

  programs.nix-ld.enable = true;

  environment.systemPackages = with pkgs; [ wget ];

  wsl = {
    enable = true;
    defaultUser = "trung";
    wslConf.user.default = "trung";
  };

  networking.hostName = "nixos-wsl";

  programs.zsh.enable = true;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    users.trung = {
      imports = [
        ../../modules/applications/shell.nix
        ../../modules/applications/nix-utils.nix
        ../../modules/applications/dev.nix
      ];

      home = {
        username = "trung";
        homeDirectory = "/home/trung";
        stateVersion = "25.11";
        sessionVariables.EDITOR = "nvim";
      };

      programs = {
        home-manager.enable = true;
        git = {
          enable = true;
          settings.user = {
            name = "Troy Hoang";
            email = "troy.hoang@laidon.com";
          };
        };
      };

      home.packages = with pkgs; [
        fd
        ripgrep
        jq
        unzip
        wget
        gh
        lazygit
      ];
    };

    backupFileExtension = "hm-backup";
  };

  users.users.trung = {
    isNormalUser = true;
    description = "Trung Hoang";
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
  };

  system.stateVersion = "25.11";
}
