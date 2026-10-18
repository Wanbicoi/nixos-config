# Home Manager programs that are not shell-related.
{ ... }:

{
  # Identity (name/email) is per-user; see home/<user>/identity.nix.
  programs.git.enable = true;
}
