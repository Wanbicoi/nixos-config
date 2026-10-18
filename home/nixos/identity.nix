# Who this profile is: names, paths, and Home Manager itself.
{ ... }:

{
  programs.home-manager.enable = true;

  home = {
    username = "nixos";
    homeDirectory = "/home/nixos";
  };

  programs.git.settings.user = {
    name = "Trung Hoang";
    email = "wanbicoi123@gmail.com";
  };
}
