# User-level packages for every machine.
{
  inputs,
  pkgs,
  ...
}:

{
  home.packages =
    (with pkgs; [
      neovim
      tree-sitter

      # Nix LSP + formatter for the editor (nvim LSP / conform).
      nixd

      lazygit
      delta
      mpg123
      python3
      pnpm
      nodejs
      cargo
      rustc
      go

      gcc
      gnumake
      sops
      age

      # utils
      ripgrep
      fd
      jq
      gh
      unzip

      # playwright-cli on PATH, run through npx (no local packaging yet).
      # Browser binaries are downloaded by the CLI itself (`playwright-cli
      # install-browser chromium`); nix-ld supplies their runtime libraries, so
      # no Chromium package is needed here.
      (writeShellApplication {
        name = "playwright-cli";
        runtimeInputs = [ nodejs ];
        text = ''
          exec npx --yes @playwright/cli@latest "$@"
        '';
      })
    ])
    ++ [
      inputs.tuicr.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
}
