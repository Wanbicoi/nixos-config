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
      yarn
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

      # playwright-cli on PATH, run through pnpm dlx (no local packaging yet).
      # Pinned: each CLI release bundles a playwright-core that expects one
      # Chromium revision (0.1.22 -> 1247), so a floating version breaks the
      # installed browser. To bump, pick the new version, then run
      # `playwright-cli install-browser chromium` to fetch its revision.
      # Browser binaries are downloaded by the CLI itself; nix-ld supplies
      # their runtime libraries, so no Chromium package is needed here.
      (writeShellApplication {
        name = "playwright-cli";
        runtimeInputs = [
          nodejs
          pnpm
        ];
        text = ''
          exec pnpm dlx --package=@playwright/cli@0.1.22 playwright-cli "$@"
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
