# sops secrets for the Laidon company profile (troy).
#
# This profile only decrypts secrets/laidon.yaml (its own age key — see
# .sops.yaml). It never renders the personal profile's secrets, and it holds
# no key that could decrypt them.
{
  config,
  ...
}:

{
  sops = {
    defaultSopsFile = ../../secrets/laidon.yaml;

    secrets.CF_USERNAME = { };
    secrets.CF_PASSWORD = { };
    templates."shell.env" = {
      mode = "0400";
      content = ''
        export CF_USERNAME="${config.sops.placeholder.CF_USERNAME}"
        export CF_PASSWORD="${config.sops.placeholder.CF_PASSWORD}"
      '';
    };
  };
}
