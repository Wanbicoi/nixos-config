# nixconfig — convenience wrappers around nixos-rebuild, flake, hooks and
# submodule maintenance. Run `make` (or `make help`) to list targets.

# Default HOST to current machine's hostname (e.g. "wsl" or "wsl-laidon")
HOST ?= $(shell hostname)
FLAKE ?= .
NVIM_DIR ?= submodules/nvim
AGENT_DIR ?= submodules/agent-config
LAZYGIT_DIR ?= submodules/lazygit
JOURNALS_DIR ?= submodules/journals
AGENT_REMOTE ?= git@github.com:CHANGE_ME/agent-config.git
FILE ?= secrets/personal.yaml

# Distro that switch-laidon must run in (WSL exports WSL_DISTRO_NAME).
# Override if it was imported under another name:
#   make switch-laidon LAIDON_DISTRO=NixOS-Laidon
LAIDON_DISTRO ?= wsl-laidon

NIXOS_REBUILD = sudo nixos-rebuild

.DEFAULT_GOAL := secrets-edit

.PHONY: help switch build test boot dry rollback generations \
        update update-input upgrade check hooks \
        nvim-init nvim-update secrets-edit \
        agent-init agent-update agent-remote \
        lazygit-init lazygit-update \
        journals-init journals-update journals-deps

help: ## Show this help
	@grep -hE '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) \
		| sort \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-14s\033[0m %s\n", $$1, $$2}'

## --- system ---

switch: ## Build + activate HOST (defaults to current host)
	@if [ "$(HOST)" = "wsl-laidon" ] && [ "$${WSL_DISTRO_NAME:-}" != "$(LAIDON_DISTRO)" ] && [ "$$(hostname)" != "wsl-laidon" ]; then \
		echo "refusing: this is '$${WSL_DISTRO_NAME:-<not WSL>}', not '$(LAIDON_DISTRO)'"; \
		echo "wsl-laidon swaps the nixos/troy uids; run it in the company distro."; \
		exit 1; \
	fi
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

## --- flake ---

update: ## Update all flake inputs
	nix flake update

update-input: ## Update one input: make update-input INPUT=llm-agents
	@test -n "$(INPUT)" || { echo "usage: make update-input INPUT=<name>"; exit 1; }
	nix flake update $(INPUT)

upgrade: update switch ## Update inputs, then activate HOST

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

## --- agent config submodule (Pi / Claude Code / OpenCode) ---

agent-init: ## Clone the agent-config submodule
	git submodule update --init --recursive $(AGENT_DIR)

agent-update: ## Pull the latest agent-config, stage the new pointer
	git submodule update --remote $(AGENT_DIR)
	git add $(AGENT_DIR)

agent-remote: ## Point agent-config at your remote: make agent-remote AGENT_REMOTE=git@github.com:you/agent-config.git
	git submodule set-url $(AGENT_DIR) $(AGENT_REMOTE)
	git submodule sync $(AGENT_DIR)
	@echo "Updated $(AGENT_DIR) URL. Commit .gitmodules, then push the repo."

## --- lazygit config submodule ---

lazygit-init: ## Clone the lazygit submodule
	git submodule update --init --recursive $(LAZYGIT_DIR)

lazygit-update: ## Pull the latest lazygit config, stage the new pointer
	git submodule update --remote $(LAZYGIT_DIR)
	git add $(LAZYGIT_DIR)

## --- journals submodule ---

journals-init: ## Clone the journals submodule and install its dependencies
	git submodule update --init --recursive $(JOURNALS_DIR)
	$(MAKE) journals-deps

journals-update: ## Pull the latest journals, stage the new pointer
	git submodule update --remote $(JOURNALS_DIR)
	git add $(JOURNALS_DIR)

journals-deps: ## Install journals dependencies (run as the checkout owner)
	cd $(JOURNALS_DIR) && bun install --frozen-lockfile

## --- secrets ---

secrets-edit: ## Edit encrypted secrets (FILE=secrets/personal.yaml)
	sops $(FILE)
