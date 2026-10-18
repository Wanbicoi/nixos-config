{
  description = "Nix configuration for laptops, NixOS-WSL, and macOS";

  nixConfig = {
    extra-substituters = [ "https://cache.numtide.com" ];
    extra-trusted-public-keys = [
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # NOTE: intentionally no `nixpkgs.follows` — llm-agents.nix is tested
    # against its own pinned nixpkgs-unstable. Leaving it independent also
    # lets us pull pre-built binaries from the Numtide cache.
    llm-agents.url = "github:numtide/llm-agents.nix";

    # Declarative git pre-commit hooks.
    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Uncomment when adding a Mac (nix-darwin):
    # nix-darwin = {
    #   url = "github:nix-darwin/nix-darwin";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  outputs =
    inputs@{ nixpkgs, ... }:
    let
      lib = nixpkgs.lib;
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      # Build a NixOS host from hosts/<hostname>. The host directory decides
      # which platform (WSL, laptop, ...) and user modules it pulls in.
      mkNixos =
        hostname: system:
        lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [ ./hosts/${hostname} ];
        };

      # Pre-commit hooks: run by `nix flake check`, installed by `nix develop`.
      pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
        src = ./.;
        hooks = {
          nixfmt.enable = true;

          # Add more from https://github.com/cachix/git-hooks.nix, e.g.:
          # statix.enable = true;
          # deadnix.enable = true;
        };
      };
    in
    {
      nixosConfigurations = {
        wsl = mkNixos "wsl" system;

        # Add more NixOS machines here, e.g.:
        # thinkbook = mkNixos "thinkbook" system;
      };

      # `nix fmt` / `make fmt`.
      formatter.${system} = pkgs.nixfmt-tree;

      checks.${system}.pre-commit-check = pre-commit-check;

      devShells.${system}.default = pkgs.mkShell {
        inherit (pre-commit-check) shellHook;
        buildInputs = pre-commit-check.enabledPackages;
      };

      # Uncomment and extend when adding nix-darwin machines:
      # darwinConfigurations = {
      #   macbook = inputs.nix-darwin.lib.darwinSystem {
      #     system = "aarch64-darwin";
      #     specialArgs = { inherit inputs; };
      #     modules = [ ./hosts/macbook ];
      #   };
      # };
    };
}
