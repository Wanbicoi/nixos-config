# Who this profile is: names, paths, and Home Manager itself.
{ ... }:

{
  programs.home-manager.enable = true;

  home = {
    username = "troy";
    homeDirectory = "/home/troy";
  };

  programs.git.settings.user = {
    name = "Troy Hoang";
    email = "troy.hoang@laidon.com";
  };
}
