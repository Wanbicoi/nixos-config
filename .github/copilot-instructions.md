# Project Guidelines

## Architecture
- Flake entrypoint is in `flake.nix`; active host output is `nixosConfigurations.thinkpad`, which maps to `hosts/laptop-thinkbook-14-g6-irl`.
- Module layering is: `hosts/*` (machine-specific) -> `modules/core/*` (system services) -> `modules/core/user.nix` (Home Manager bridge) -> `modules/desktop/hyprland/*` and `modules/applications/*` (user environment).
- Add new modules in the closest orchestrator file (for example `modules/core/default.nix` or `modules/desktop/hyprland/default.nix`) instead of importing ad hoc from host files.

## Build and Test
- System-changing commands (require approval because they need `sudo` and modify the live system):
  - `sudo nixos-rebuild test --flake .#thinkpad`
  - `sudo nixos-rebuild switch --flake .#thinkpad`
- When updating inputs, run `nix flake update` before rebuild commands.

## Conventions
- Use host name `thinkpad` for rebuild commands; README examples referencing `nixos` are legacy and should not be used for new changes.
- Home Manager is configured under `home-manager.users.trung` in `modules/core/user.nix`; preserve `backupFileExtension` behavior to avoid clobbering existing dotfiles.
- Keep paths relative inside Nix modules; Hyprland assets (for example lockscreen wallpaper) rely on repo-local paths under `wallpapers/`.
- Hyprland keybind ordering matters: if submap/catchall generation is unreliable, place related rules together in `wayland.windowManager.hyprland.extraConfig`.
- Keep disabled modules commented unless the task explicitly enables them; enabling multiple desktop/audio stacks can conflict.

## Documentation
- See `README.md` for setup and rebuild walkthroughs.
- For lockscreen visuals and paths, use `modules/desktop/hyprland/hyprlock.nix` as the source of truth.
- If documentation and code disagree, follow current code in `flake.nix` and `hosts/laptop-thinkbook-14-g6-irl/default.nix`.
