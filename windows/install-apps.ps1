# PowerShell script to install Windows apps via Winget and set up terminal configs
$ErrorActionPreference = "Continue"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$appsFile = Join-Path $scriptDir "apps.txt"

if (-not (Test-Path $appsFile)) {
    Write-Error "apps.txt not found at $appsFile"
    exit 1
}

Write-Host "==> Installing packages from $appsFile..." -ForegroundColor Cyan

Get-Content $appsFile | ForEach-Object {
    $line = $_.Trim()
    if ($line -and -not $line.StartsWith("#")) {
        # Strip trailing inline comments if any
        $appId = ($line -split "#")[0].Trim()
        Write-Host "Installing: $appId" -ForegroundColor Yellow
        winget install --id $appId -e --accept-package-agreements --accept-source-agreements
    }
}

# Restore Alacritty config
$alacrittySource = Join-Path $scriptDir "alacritty\alacritty.toml"
if (Test-Path $alacrittySource) {
    $alacrittyDestDir = Join-Path $env:APPDATA "alacritty"
    New-Item -ItemType Directory -Force -Path $alacrittyDestDir | Out-Null
    Copy-Item $alacrittySource (Join-Path $alacrittyDestDir "alacritty.toml") -Force
    Write-Host "==> Restored Alacritty config to $alacrittyDestDir\alacritty.toml" -ForegroundColor Green
}

# Restore WezTerm config
$weztermSource = Join-Path $scriptDir "wezterm\wezterm.lua"
if (Test-Path $weztermSource) {
    $weztermDestDir = Join-Path $env:USERPROFILE ".config\wezterm"
    New-Item -ItemType Directory -Force -Path $weztermDestDir | Out-Null
    Copy-Item $weztermSource (Join-Path $weztermDestDir "wezterm.lua") -Force
    Write-Host "==> Restored WezTerm config to $weztermDestDir\wezterm.lua" -ForegroundColor Green
}

Write-Host "==> Done!" -ForegroundColor Green
