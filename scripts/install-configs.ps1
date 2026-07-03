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

# ── Claude global instructions + settings ─────────────────────────────────────

Write-Header "Claude"

# AGENTS.md is the single source of truth; both Claude Code and OpenCode read it
Write-Step "~\.claude\AGENTS.md"
Install-Link "$REPO\AGENTS.md"  "$env:USERPROFILE\.claude\AGENTS.md"
Write-Step "~\.claude\CLAUDE.md  (-> AGENTS.md)"
Install-Link "$REPO\AGENTS.md"  "$env:USERPROFILE\.claude\CLAUDE.md"

# CLAUDE.md in the repo itself is a local symlink to AGENTS.md
$repoClaudeMd = "$REPO\CLAUDE.md"
if (-not (Test-Path $repoClaudeMd)) {
    try {
        New-Item -ItemType SymbolicLink -Path $repoClaudeMd -Target "$REPO\AGENTS.md" -ErrorAction Stop | Out-Null
        Write-Ok "$repoClaudeMd -> AGENTS.md"
    } catch {
        Write-Fail "Could not create repo CLAUDE.md symlink: $_"
    }
} else {
    Write-Ok "CLAUDE.md symlink already exists"
}

Write-Step "~\.claude\settings.json"
Install-Link "$REPO\claude\settings.json"  "$env:USERPROFILE\.claude\settings.json"

# ── OpenCode ──────────────────────────────────────────────────────────────────

Write-Header "OpenCode"
Write-Step "~\.config\opencode\opencode.json"
Install-Link "$REPO\.config\opencode\opencode.json"  "$env:USERPROFILE\.config\opencode\opencode.json"

# ── WezTerm ───────────────────────────────────────────────────────────────────

Write-Header "WezTerm"
Write-Step "~\.wezterm.lua"
Install-Link "$REPO\.config\wezterm\wezterm.lua"  "$env:USERPROFILE\.wezterm.lua"

# Mux server logon task: keeps sessions alive across GUI restarts.
# wezterm.lua connects to the 'main' unix domain served by this process.
Write-Step "Scheduled task: WezTermMuxServer"
$muxExe = "$env:ProgramFiles\WezTerm\wezterm-mux-server.exe"
if (Test-Path $muxExe) {
    $action   = New-ScheduledTaskAction -Execute $muxExe -Argument '--daemonize' -WorkingDirectory $env:USERPROFILE
    $trigger  = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME
    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit (New-TimeSpan)
    Register-ScheduledTask -TaskName 'WezTermMuxServer' -Action $action -Trigger $trigger -Settings $settings -Force | Out-Null
    Write-Ok "Scheduled task 'WezTermMuxServer' registered"
} else {
    Write-Fail "wezterm-mux-server.exe not found, skipping mux logon task"
}

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
