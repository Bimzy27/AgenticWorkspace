# AgenticWorkspace

Dotfiles and agent instructions for an agentic engineering workflow on Windows 11, with optional Linux/Omarchy support.

WezTerm handles terminal multiplexing natively (tabs, panes, copy mode) via a Ctrl+Space leader key.
Claude Code is the primary AI agent harness.

## Structure

```
.
├── setup.ps1                       # One-shot Windows setup (runs all scripts below)
├── AGENTS.md                       # Agent instructions (all harnesses)
├── CLAUDE.md                       # Agent instructions (Claude Code)
├── .config/
│   ├── wezterm/wezterm.lua         # Terminal: tabs/panes, Tokyo Night, Ctrl+Space leader
│   └── nvim/                       # Neovim: lazy.nvim, oil.nvim, neogit, snacks.nvim, LSP
├── scripts/
│   └── install-configs.ps1         # Symlink configs into system paths, install fonts
└── bootstrap/
    ├── workspace-windows.ps1       # Install dev tools (winget, npm, gh extensions)
    └── windows.ps1                 # Symlink dotfiles, set up shell profile
```

## Quick start

### Windows 11

Run a single script from an elevated PowerShell 7+ prompt (or with Developer Mode enabled):

```powershell
git clone https://github.com/Bimzy27/AgenticWorkspace $env:USERPROFILE\AgenticWorkspace
cd $env:USERPROFILE\AgenticWorkspace
Set-ExecutionPolicy Bypass -Scope Process -Force
.\setup.ps1
```

`setup.ps1` runs in order:
1. `bootstrap\workspace-windows.ps1` - installs all dev tools via winget/npm/gh
2. `bootstrap\windows.ps1` - symlinks dotfiles, sets up PowerShell profile
3. `scripts\install-configs.ps1` - symlinks configs into system paths, installs IosevkaTerm Nerd Font

Each step is idempotent - safe to re-run.

> **Symlinks on Windows**: requires Developer Mode (`Settings -> System -> Developer Mode`) or an elevated prompt.

After setup:

```powershell
gh auth login           # authenticate GitHub CLI
claude                  # authenticate Claude Code
```

### Linux / Omarchy

```bash
git clone https://github.com/Bimzy27/AgenticWorkspace ~/AgenticWorkspace
cd ~/AgenticWorkspace
bash bootstrap/linux.sh
```

### Phone (remote access)

1. Install [Tailscale](https://tailscale.com) on your phone and desktop.
2. Install a terminal: [Blink Shell](https://blink.sh) (iOS) or [Termux](https://termux.dev) (Android).
3. SSH into your desktop via Tailscale hostname:
   ```
   ssh <your-machine-tailscale-name>
   ```

## WezTerm keybindings

Leader key: `Ctrl+Space`

| Key | Action |
|-----|--------|
| `Leader + \` | Split pane horizontally |
| `Leader + -` | Split pane vertically |
| `Leader + h/j/k/l` | Navigate panes (vim-style) |
| `Leader + H/J/K/L` | Resize pane |
| `Leader + z` | Zoom/unzoom pane |
| `Leader + x` | Close pane |
| `Leader + c` | New tab |
| `Leader + n/p` | Next/previous tab |
| `Leader + 1-5` | Jump to tab by number |
| `Leader + ,` | Rename tab |
| `Leader + [` | Enter copy mode (vi keys) |
| `Leader + d` | Detach mux session |

## Tools

| Tool | Purpose |
|------|---------|
| [WezTerm](https://wezfurlong.org/wezterm/) | Terminal - GPU-accelerated, native tabs/panes |
| [Neovim](https://neovim.io) | Editor |
| [Claude Code](https://claude.ai/code) | Primary AI agent harness |
| [GitHub CLI](https://cli.github.com) | Git forge integration |
| [Tailscale](https://tailscale.com) | Private network for remote access |
| [lazygit](https://github.com/jesseduffield/lazygit) | TUI git client |
| [ripgrep](https://github.com/BurntSushi/ripgrep) | Fast grep |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | Smart `cd` |

## Agent instructions

`AGENTS.md` and `CLAUDE.md` contain the agent instructions read by all harnesses.
`scripts/install-configs.ps1` symlinks both into `~/.claude/` so the instructions apply globally across every project.

To update agent instructions, edit `AGENTS.md` or `CLAUDE.md` directly.
