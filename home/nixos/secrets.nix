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
    secrets.example_secret = { };

    templates."shell.env" = {
      mode = "0400";
      content = ''
        export EXAMPLE_SECRET="${config.sops.placeholder.example_secret}"
      '';
    };
  };
}
