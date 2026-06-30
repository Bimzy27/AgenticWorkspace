#Requires -Version 7
<#
.SYNOPSIS
    Symlink dotfiles configs into their global Windows locations.

.DESCRIPTION
    Creates symlinks from this repo into the correct system config paths.
    Requires either an elevated prompt or Windows Developer Mode enabled
    (Settings > System > Developer Mode) for symlink creation.

.EXAMPLE
    pwsh -File scripts\install-configs.ps1
#>

$ErrorActionPreference = 'Stop'
$REPO = Split-Path $PSScriptRoot -Parent

function Write-Header([string]$text) {
    Write-Host "`n$text" -ForegroundColor Cyan
}

function Write-Ok([string]$text) {
    Write-Host "  [ok] $text" -ForegroundColor Green
}

function Write-Step([string]$text) {
    Write-Host "  --> $text" -ForegroundColor White
}

function Write-Fail([string]$text) {
    Write-Host "  [!]  $text" -ForegroundColor Red
}

function Install-Link {
    param([string]$Src, [string]$Dst)

    if (-not (Test-Path $Src)) {
        Write-Fail "Source not found, skipping: $Src"
        return
    }

    $dstDir = Split-Path $Dst -Parent
    if (-not (Test-Path $dstDir)) {
        New-Item -ItemType Directory -Path $dstDir -Force | Out-Null
    }

    if (Test-Path $Dst) {
        Remove-Item $Dst -Recurse -Force
    }

    try {
        New-Item -ItemType SymbolicLink -Path $Dst -Target $Src -ErrorAction Stop | Out-Null
        Write-Ok "$Dst -> $Src"
    } catch {
        Write-Fail "Failed to create symlink: $_"
        Write-Fail "Try running as Administrator or enable Developer Mode."
    }
}

# ── Claude global instructions ────────────────────────────────────────────────

Write-Header "Claude"
Write-Step "~\.claude\CLAUDE.md"
Install-Link "$REPO\CLAUDE.md"  "$env:USERPROFILE\.claude\CLAUDE.md"
Write-Step "~\.claude\AGENTS.md"
Install-Link "$REPO\AGENTS.md"  "$env:USERPROFILE\.claude\AGENTS.md"

# ── WezTerm ───────────────────────────────────────────────────────────────────

Write-Header "WezTerm"
Write-Step "~\.wezterm.lua"
Install-Link "$REPO\.config\wezterm\wezterm.lua"  "$env:USERPROFILE\.wezterm.lua"

# ── Neovim ────────────────────────────────────────────────────────────────────

Write-Header "Neovim"
Write-Step "%LOCALAPPDATA%\nvim"
Install-Link "$REPO\.config\nvim"  "$env:LOCALAPPDATA\nvim"

# ── Fonts ─────────────────────────────────────────────────────────────────────

Write-Header "Fonts"
Write-Step "IosevkaTerm Nerd Font"
$fontDir = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"
$alreadyInstalled = Test-Path "$fontDir\IosevkaTermNerdFont-Regular.ttf"
if ($alreadyInstalled) {
    Write-Ok "IosevkaTerm Nerd Font already installed"
} else {
    $zip  = "$env:TEMP\IosevkaTerm.zip"
    $extracted = "$env:TEMP\IosevkaTerm"
    Write-Step "Downloading from github.com/ryanoasis/nerd-fonts..."
    Invoke-WebRequest -Uri "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/IosevkaTerm.zip" `
        -OutFile $zip -UseBasicParsing

    Expand-Archive -Path $zip -DestinationPath $extracted -Force

    if (-not (Test-Path $fontDir)) { New-Item -ItemType Directory -Path $fontDir -Force | Out-Null }

    $regKey = "HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"
    Get-ChildItem $extracted -Include '*.ttf','*.otf' -Recurse | ForEach-Object {
        $dest = "$fontDir\$($_.Name)"
        Copy-Item $_.FullName -Destination $dest -Force
        $fontName = [System.IO.Path]::GetFileNameWithoutExtension($_.Name) + ' (TrueType)'
        Set-ItemProperty -Path $regKey -Name $fontName -Value $dest
    }

    Remove-Item $zip, $extracted -Recurse -Force -ErrorAction SilentlyContinue
    Write-Ok "IosevkaTerm Nerd Font installed - restart WezTerm to apply"
}

# ── Done ──────────────────────────────────────────────────────────────────────

Write-Host ""
Write-Host "Done." -ForegroundColor Green
