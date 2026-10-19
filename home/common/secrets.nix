# Age-encrypted secrets (see .sops.yaml + secrets/). The private key lives
# outside the repo at ~/.config/sops/age/keys.txt.
{
  config,
  inputs,
  ...
}:

{
  imports = [ inputs.sops-nix.homeManagerModules.sops ];

  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    defaultSopsFile = ../../secrets/common.yaml;

    # Every secret must be declared here, otherwise sops-nix never decrypts it
    # even when it exists in secrets/common.yaml. Declaring it also creates
    # ~/.config/sops-nix/secrets/<name> for `sops.placeholder` and for
    # `sops.secrets.<name>.path` consumers (scripts, systemd units).
    # TODO: remove example_secret
    secrets.example_secret = { };
    secrets.CF_USERNAME = { };
    secrets.CF_PASSWORD = { };

    templates."shell.env" = {
      mode = "0400";
      content = ''
        export EXAMPLE_SECRET="${config.sops.placeholder.example_secret}"
        export CF_USERNAME="${config.sops.placeholder.CF_USERNAME}"
        export CF_PASSWORD="${config.sops.placeholder.CF_PASSWORD}"
      '';
    };
  };
}
