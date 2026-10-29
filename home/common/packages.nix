# User-level packages for every machine.
{
  inputs,
  pkgs,
  ...
}:

{
  home.packages =
    (with pkgs; [
      # apps
      neovim
      tree-sitter
      lazygit
      delta
      mpg123

      # Nix LSP + formatter for the editor (nvim LSP / conform).
      nixd

      python3

      # nodes
      pnpm
      bun
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

      # Caveman CLI (`caveman` / `cave`) via pnpm dlx.
      (writeShellApplication {
        name = "caveman";
        runtimeInputs = [
          nodejs
          pnpm
        ];
        text = ''
          exec pnpm dlx --package=@caveman-ai/cli caveman "$@"
        '';
      })
      (writeShellApplication {
        name = "cave";
        runtimeInputs = [
          nodejs
          pnpm
        ];
        text = ''
          exec pnpm dlx --package=@caveman-ai/cli cave "$@"
        '';
      })
    ])
    ++ [
      inputs.tuicr.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
}
