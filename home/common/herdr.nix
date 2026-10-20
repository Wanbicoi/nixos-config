# Herdr settings (~/.config/herdr/config.toml). Herdr itself is installed
# system-wide by modules/nixos/herdr.nix.
#
# The file becomes a read-only store symlink, so settings changed from inside
# herdr (or `herdr config reset-keys`) no longer persist: change them here.
# After `make switch`, run `herdr server reload-config` to apply.
{ pkgs, ... }:

{
  xdg.configFile."herdr/config.toml".source = (pkgs.formats.toml { }).generate "herdr-config.toml" {
    onboarding = false;

    theme = {
      name = "rose-pine-dawn";
      auto_switch = false;
    };

    ui = {
      status_indicators = "symbols";
      # "auto" draws herdr's own cursor on WSL, which ignores the cursor shape
      # apps request (e.g. Neovim's bar in insert mode).
      host_cursor = "native";
      # Ask the outer terminal to show a desktop notification.
      toast.delivery = "terminal";
    };
  };
}
