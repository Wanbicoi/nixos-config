# User-level packages for every machine.
{
  pkgs,
  ...
}:

let
  # Bun's built-in linter (`bun lint`) only exists in the canary channel as of
  # 1.4.4. Pin the canary npm binary until nixpkgs packages a stable release
  # that includes it (1.5+), then switch back to `pkgs.bun`.
  bunPinned =
    if pkgs.stdenvNoCC.hostPlatform.system == "x86_64-linux" then
      pkgs.bun.overrideAttrs (
        finalAttrs: _prev: {
          version = "1.4.4-canary.20261106.1";

          # Canary builds are published to npm, not GitHub Releases.
          src = pkgs.fetchurl {
            url = "https://registry.npmjs.org/@oven/bun-linux-x64-baseline/-/bun-linux-x64-baseline-${finalAttrs.version}.tgz";
            hash = "sha256-ftumGesW+qAlPq4dHrgPCLePLkpI+bLLKInF+QxIEoE=";
          };

          sourceRoot = "package";

          installPhase = ''
            runHook preInstall
            install -Dm755 ./bin/bun $out/bin/bun
            ln -s $out/bin/bun $out/bin/bunx
            runHook postInstall
          '';
        }
      )
    else
      pkgs.bun;
in
{
  home.packages = (
    with pkgs;
    [
      # apps
      neovim
      tree-sitter
      lazygit
      delta
      mpg123

      # Nix LSP + formatter for the editor (nvim LSP / conform).
      nixd

      # python3
      python3
      uv

      # nodes
      pnpm
      yarn
      bunPinned
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
    ]
  );
}
