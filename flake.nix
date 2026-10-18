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

      # Build a NixOS host from hosts/<hostname>. The host directory decides
      # which platform (WSL, laptop, ...) and user modules it pulls in.
      mkNixos =
        hostname: system:
        lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [ ./hosts/${hostname} ];
        };
    in
    {
      nixosConfigurations = {
        wsl = mkNixos "wsl" "x86_64-linux";

        # Add more NixOS machines here, e.g.:
        # thinkbook = mkNixos "thinkbook" "x86_64-linux";
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
