# Home Manager programs that are not shell-related.
{ ... }:

{
  programs.git = {
    enable = true;
    settings.user = {
      name = "Troy Hoang";
      email = "troy.hoang@laidon.com";
    };
  };
}
