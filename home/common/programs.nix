# Home Manager programs that are not shell-related.
{ lib, ... }:

{
  # Identity (name/email) is per-user; see home/<user>/identity.nix.
  programs.git.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    config = {
      global = {
        hide_env_diff = true;
      };
    };
  };

  # programs.git writes ~/.config/git/config as a read-only store symlink, so
  # anything that runs `git config --global` (glab, gh, gcloud, ...) fails with
  # "could not lock config file ... Read-only file system".
  #
  # Git uses ~/.gitconfig as the `--global` file whenever it exists, so give
  # every user a real, writable one. It is intentionally empty: real git
  # commands read both global files, so the declarative settings in
  # ~/.config/git/config still apply, while `git config --global` writes land
  # here instead of in the read-only store symlink.
  home.activation.gitWritableGlobal = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [[ ! -e "$HOME/.gitconfig" ]]; then
      $DRY_RUN_CMD touch "$HOME/.gitconfig"
    fi
  '';
}
