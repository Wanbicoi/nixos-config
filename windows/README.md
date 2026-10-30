# Windows App & Terminal Configuration Backup

Backup of host Windows applications installed via Winget and terminal configurations.

## Contents

- `apps.txt` - Curated list of Winget IDs for installed applications (terminals, dev tools, productivity, utilities).
- `install-apps.ps1` - PowerShell script to batch install all applications and restore terminal configurations.
- `alacritty/alacritty.toml` - Alacritty configuration (`JetBrainsMono Nerd Font`, `rose-pine-dawn`, auto-launches WSL with `herdr`).
- `wezterm/wezterm.lua` - WezTerm configuration (`rose-pine-dawn`, workspaces, custom keybindings).

## How to Restore on Windows

Open PowerShell (as administrator or standard user) and run:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\install-apps.ps1
```

Or from WSL directly:

```bash
powershell.exe -ExecutionPolicy Bypass -File "$(wslpath -w /srv/nixconfig/windows/install-apps.ps1)"
```

## Apps requiring manual download / setup

- **Google Chrome**: Standalone installer
- **FortiClient VPN**: Corporate portal / installer
- **Edge / Chrome PWAs**: ChatGPT, Google Gemini, LeetCode, DesignGuru
