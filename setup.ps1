#Requires -Version 7
<#
.SYNOPSIS
    One-shot Windows setup for AgenticWorkspace.

.DESCRIPTION
    Runs all setup scripts in the correct order:
      1. bootstrap\workspace-windows.ps1 - installs dev tools via winget/npm/gh
      2. bootstrap\windows.ps1           - symlinks dotfiles, sets up shell profile
      3. scripts\install-configs.ps1     - symlinks configs, installs fonts

    Safe to re-run - each step is idempotent.

.PARAMETER SkipVSCode
    Pass through to workspace-windows.ps1 to skip VS Code and its extensions.

.PARAMETER SkipExtensions
    Pass through to workspace-windows.ps1 to skip VS Code extension installation.

.EXAMPLE
    # Elevated PowerShell 7+ prompt, or Developer Mode enabled
    Set-ExecutionPolicy Bypass -Scope Process -Force
    .\setup.ps1
#>

param(
    [switch]$SkipVSCode,
    [switch]$SkipExtensions
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$REPO = $PSScriptRoot

function Write-Banner([string]$text) {
    Write-Host ""
    Write-Host "━━━ $text " -ForegroundColor Cyan -NoNewline
    Write-Host ("━" * [Math]::Max(0, 60 - $text.Length)) -ForegroundColor Cyan
}

Write-Host ""
Write-Host "AgenticWorkspace setup" -ForegroundColor Cyan
Write-Host "Repo: $REPO"

# ── Step 1: Workspace tools ────────────────────────────────────────────────────

Write-Banner "Step 1/3 - Workspace tools"

$wsArgs = @()
if ($SkipVSCode)     { $wsArgs += '-SkipVSCode' }
if ($SkipExtensions) { $wsArgs += '-SkipExtensions' }

& "$REPO\bootstrap\workspace-windows.ps1" @wsArgs
if ($LASTEXITCODE -and $LASTEXITCODE -ne 0) {
    Write-Host "workspace-windows.ps1 exited $LASTEXITCODE - continuing" -ForegroundColor Yellow
}

# ── Step 2: Dotfiles symlinks + shell profile ──────────────────────────────────

Write-Banner "Step 2/3 - Dotfiles"

& "$REPO\bootstrap\windows.ps1"
if ($LASTEXITCODE -and $LASTEXITCODE -ne 0) {
    Write-Host "windows.ps1 exited $LASTEXITCODE - continuing" -ForegroundColor Yellow
}

# ── Step 3: Config symlinks + fonts ───────────────────────────────────────────

Write-Banner "Step 3/3 - Configs and fonts"

& "$REPO\scripts\install-configs.ps1"
if ($LASTEXITCODE -and $LASTEXITCODE -ne 0) {
    Write-Host "install-configs.ps1 exited $LASTEXITCODE - continuing" -ForegroundColor Yellow
}

# ── Done ──────────────────────────────────────────────────────────────────────

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""
Write-Host "Setup complete." -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Restart your terminal to pick up PATH changes"
Write-Host "  2. Run:  gh auth login"
Write-Host "  3. Run:  claude              # authenticate with Anthropic"
Write-Host ""
