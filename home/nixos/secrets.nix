# sops secrets for the personal profile (nixos).
#
# Each persona gets its own sops file (see .sops.yaml recipient rules): the
# personal key at age1mggn… cannot decrypt secrets/laidon.yaml, and vice
# versa. Only the secrets this profile actually uses are declared here, so a
# company secret never renders into the personal home.
{
  config,
  ...
}:

{
  sops = {
    defaultSopsFile = ../../secrets/personal.yaml;

    secrets.example_secret = { };
    templates."shell.env" = {
      mode = "0400";
      content = ''
        export EXAMPLE_SECRET="${config.sops.placeholder.example_secret}"
      '';
    };
  };
}
