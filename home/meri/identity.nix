# Who this profile is: names, paths, and Home Manager itself.
{ ... }:

{
  programs.home-manager.enable = true;

  home = {
    username = "meri";
    homeDirectory = "/home/meri";
  };
}
