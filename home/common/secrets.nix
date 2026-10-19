# Age-encrypted secrets (see .sops.yaml + secrets/). The private key lives
# outside the repo at ~/.config/sops/age/keys.txt.
#
# This module wires sops-nix into every profile and sets the per-user key
# path. It deliberately declares *no* secrets and no templates: each profile
# declares its own in home/<user>/secrets.nix, pointing `defaultSopsFile` at
# that persona's ciphertext, so two users never decrypt (or even name) the
# same file.
{
  config,
  inputs,
  ...
}:

{
  imports = [ inputs.sops-nix.homeManagerModules.sops ];

  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
  };
}
