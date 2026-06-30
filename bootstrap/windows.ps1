# bootstrap/windows.ps1 - set up dotfiles on Windows 11
# Run from an elevated PowerShell 7+ prompt:
#   Set-ExecutionPolicy Bypass -Scope Process -Force
#   .\bootstrap\windows.ps1
#
# Or non-elevated if Developer Mode is enabled (for symlinks).

param(
    [switch]$SymlinksOnly
)

$ErrorActionPreference = 'Stop'
$DOTFILES = Split-Path $PSScriptRoot -Parent

function Link-Item {
    param($Src, $Dst)
    $dstDir = Split-Path $Dst -Parent
    if (-not (Test-Path $dstDir)) { New-Item -ItemType Directory -Path $dstDir -Force | Out-Null }
    if (Test-Path $Dst) { Remove-Item $Dst -Recurse -Force }
    New-Item -ItemType SymbolicLink -Path $Dst -Target $Src | Out-Null
    Write-Host "  linked: $Dst -> $Src"
}

# ── Symlinks ──────────────────────────────────────────────────────────────────

Write-Host "Creating symlinks..."

# WezTerm - reads from USERPROFILE\.wezterm.lua or AppData
Link-Item "$DOTFILES\.config\wezterm\wezterm.lua" "$env:USERPROFILE\.wezterm.lua"

# Neovim - AppData\Local\nvim
Link-Item "$DOTFILES\.config\nvim" "$env:LOCALAPPDATA\nvim"

# AGENTS.md → Claude global config
$claudeDir = "$env:USERPROFILE\.claude"
if (-not (Test-Path $claudeDir)) { New-Item -ItemType Directory -Path $claudeDir -Force | Out-Null }
Link-Item "$DOTFILES\AGENTS.md" "$claudeDir\CLAUDE.md"

# CLAUDE.md in repo → AGENTS.md (same-directory symlink)
$claudeMd = "$DOTFILES\CLAUDE.md"
if (Test-Path $claudeMd) { Remove-Item $claudeMd -Force }
New-Item -ItemType SymbolicLink -Path $claudeMd -Target "$DOTFILES\AGENTS.md" | Out-Null
Write-Host "  linked: $claudeMd -> AGENTS.md"

if ($SymlinksOnly) { Write-Host "Done (symlinks only)."; exit 0 }

# ── Winget packages ───────────────────────────────────────────────────────────

Write-Host ""
Write-Host "Installing packages via winget..."

$packages = @(
    @{ Id = 'wez.wezterm';               Name = 'WezTerm' },
    @{ Id = 'Neovim.Neovim';             Name = 'Neovim' },
    @{ Id = 'Git.Git';                   Name = 'Git' },
    @{ Id = 'BurntSushi.ripgrep.MSVC';   Name = 'ripgrep' },
    @{ Id = 'sharkdp.fd';                Name = 'fd' },
    @{ Id = 'junegunn.fzf';              Name = 'fzf' },
    @{ Id = 'ajeetdsouza.zoxide';        Name = 'zoxide' },
    @{ Id = 'sharkdp.bat';               Name = 'bat' },
    @{ Id = 'eza-community.eza';         Name = 'eza' },
    @{ Id = 'JesseDuffield.lazygit';     Name = 'lazygit' },
    @{ Id = 'OpenJS.NodeJS.LTS';         Name = 'Node.js LTS' },
    @{ Id = 'GoLang.Go';                 Name = 'Go' },
    @{ Id = 'Microsoft.PowerShell';      Name = 'PowerShell 7' }
)

foreach ($pkg in $packages) {
    Write-Host "  Installing $($pkg.Name)..."
    winget install --id $pkg.Id -e --accept-source-agreements --accept-package-agreements --silent 2>$null
    if (-not $?) { Write-Warning "  $($pkg.Name) may already be installed or failed — continuing." }
}

# ── Claude Code ───────────────────────────────────────────────────────────────

Write-Host ""
Write-Host "Installing Claude Code..."
npm install -g @anthropic-ai/claude-code

# ── PowerShell profile ────────────────────────────────────────────────────────

$profileContent = @'

# dotfiles
Invoke-Expression (& { (zoxide init powershell | Out-String) })
'@

if (-not (Test-Path $PROFILE)) {
    New-Item -ItemType File -Path $PROFILE -Force | Out-Null
}

if (-not (Select-String -Path $PROFILE -Pattern 'dotfiles' -Quiet)) {
    Add-Content -Path $PROFILE -Value $profileContent
    Write-Host "Updated PowerShell profile: $PROFILE"
}

Write-Host ""
Write-Host "Bootstrap complete. Restart your terminal."
