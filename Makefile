# nixconfig — convenience wrappers around nixos-rebuild, flake, hooks and
# submodule maintenance. Run `make` (or `make help`) to list targets.

HOST ?= wsl
FLAKE ?= .
NVIM_DIR ?= nvim

NIXOS_REBUILD = sudo nixos-rebuild

.DEFAULT_GOAL := help

.PHONY: help switch build test boot dry update update-input upgrade \
        fmt fmt-check check hooks gc generations rollback \
        nvim-init nvim-update clean

help: ## Show this help
	@grep -hE '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) \
		| sort \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-14s\033[0m %s\n", $$1, $$2}'

## --- system ---

switch: ## Build + activate HOST (default: wsl)
	$(NIXOS_REBUILD) switch --flake $(FLAKE)#$(HOST)

build: ## Build HOST without activating
	$(NIXOS_REBUILD) build --flake $(FLAKE)#$(HOST)

test: ## Activate HOST until the next reboot
	$(NIXOS_REBUILD) test --flake $(FLAKE)#$(HOST)

boot: ## Set HOST as the default boot entry
	$(NIXOS_REBUILD) boot --flake $(FLAKE)#$(HOST)

dry: ## Show what `switch` would change
	$(NIXOS_REBUILD) dry-activate --flake $(FLAKE)#$(HOST)

rollback: ## Roll the system back to the previous generation
	$(NIXOS_REBUILD) switch --rollback

generations: ## List system generations
	$(NIXOS_REBUILD) list-generations

gc: ## Garbage-collect old system generations
	sudo nix-collect-garbage -d

## --- flake ---

update: ## Update all flake inputs
	nix flake update

update-input: ## Update one input: make update-input INPUT=llm-agents
	@test -n "$(INPUT)" || { echo "usage: make update-input INPUT=<name>"; exit 1; }
	nix flake update $(INPUT)

upgrade: update switch ## Update inputs, then activate HOST

fmt: ## Format all Nix files
	nix fmt

fmt-check: ## Check Nix formatting without writing
	nix fmt -- --ci

check: ## Evaluate/check the flake (runs pre-commit hooks)
	nix flake check

hooks: ## Install/refresh the git pre-commit hooks
	nix develop -c true

## --- neovim config submodule ---

nvim-init: ## Clone the nvim-config submodule
	git submodule update --init --recursive $(NVIM_DIR)

nvim-update: ## Pull the latest nvim-config, stage the new pointer
	git submodule update --remote $(NVIM_DIR)
	git add $(NVIM_DIR)

clean: ## Remove build result symlinks
	rm -f result result-*
