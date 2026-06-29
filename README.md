# dotfiles

Agentic engineering dotfiles — multi-OS (Windows 11 + Linux/Omarchy + phone via SSH).

Emulates the L8 agentic engineering workflow: tmux session splits with an agent on the left and Neovim on the right, phone access via Tailscale + mosh, parallel tasks via git worktrees.

## Structure

```
.
├── AGENTS.md                  # Source of truth — agent instructions for all harnesses
├── CLAUDE.md                  # Symlink → AGENTS.md (Claude Code reads this)
├── .config/
│   ├── wezterm/wezterm.lua    # Terminal: multi-OS, frameless, Tokyo Night
│   ├── tmux/tmux.conf         # Multiplexer: Ctrl+a prefix, vi keys, top status bar
│   └── nvim/                  # Neovim: lazy.nvim, oil.nvim, neogit, snacks.nvim, LSP
├── scripts/
│   ├── tdev.sh                # Launch tmux dev session (agent left | nvim right)
│   └── sync.sh                # Pull latest and re-apply symlinks
└── bootstrap/
    ├── linux.sh               # Arch/Omarchy or Debian/Ubuntu setup
    └── windows.ps1            # Windows 11 setup (requires elevated prompt)
```

## Quick start

### Linux / Omarchy

```bash
git clone https://github.com/<you>/dotfiles ~/dotfiles
cd ~/dotfiles
bash bootstrap/linux.sh
```

### Windows 11

Two scripts, run in order:

**1. Workspace installer** — installs all development tools (run once on a fresh machine):

```powershell
# Elevated PowerShell 7+
Set-ExecutionPolicy Bypass -Scope Process -Force
.\bootstrap\workspace-windows.ps1
```

Installs: Git · GitHub CLI · WezTerm · Neovim · VS Code (+ Claude Code & Copilot extensions) · Claude for Desktop · Claude CLI · GitHub Copilot CLI

**2. Dotfiles setup** — symlinks configs and sets up shell (run after workspace install):

```powershell
.\bootstrap\windows.ps1
```

Full sequence on a fresh machine:

```powershell
git clone https://github.com/<you>/dotfiles $env:USERPROFILE\dotfiles
cd $env:USERPROFILE\dotfiles
Set-ExecutionPolicy Bypass -Scope Process -Force
.\bootstrap\workspace-windows.ps1   # install tools
.\bootstrap\windows.ps1             # apply dotfiles
```

> **Symlinks on Windows**: requires Developer Mode (`Settings → System → Developer Mode`) or an elevated prompt. The bootstrap script handles this. Without elevation, run `.\bootstrap\windows.ps1 -SymlinksOnly` after enabling Developer Mode.

### Phone (remote access)

1. Install [Tailscale](https://tailscale.com) on your phone and your desktop.
2. Install a terminal app: [Blink Shell](https://blink.sh) (iOS) or [Termux](https://termux.dev) (Android).
3. SSH or mosh into your desktop by its Tailscale IP/hostname:
   ```
   mosh <your-machine-tailscale-name>
   ```
4. Attach to your running tmux session:
   ```
   tmux attach -t dev
   ```

## Workflow

### Starting a dev session

```bash
tdev [session-name] [project-dir]
# e.g.:
tdev myproject ~/code/myproject
```

This creates a tmux session with:
- **Left pane (60%)**: Claude Code (or OpenCode)
- **Right pane (40%)**: Neovim

### Parallel agent tasks

Each parallel task gets its own git worktree:

```bash
git worktree add ../myproject-feat-x feat/x
tdev feat-x ../myproject-feat-x
```

### Syncing dotfiles

```bash
dotfiles-sync   # or: bash ~/dotfiles/scripts/sync.sh
```

## AGENTS.md / CLAUDE.md

`AGENTS.md` is the single source of truth for all agent instructions. `CLAUDE.md` is a symlink to it, so both Claude Code and OpenCode/Codex read the same file.

**To update agent instructions**: edit `AGENTS.md` only. The symlink ensures all harnesses see the change immediately.

The global `~/.claude/CLAUDE.md` is also symlinked to `AGENTS.md`, so these instructions apply to every project unless overridden by a project-level `AGENTS.md`.

## Tools

| Tool | Purpose |
|------|---------|
| [WezTerm](https://wezfurlong.org/wezterm/) | Terminal (multi-OS, GPU-accelerated) |
| [tmux](https://github.com/tmux/tmux) | Session/pane management |
| [Neovim](https://neovim.io) | Editor |
| [Claude Code](https://claude.ai/code) | Primary AI agent harness |
| [OpenCode](https://opencode.ai) | Secondary AI agent harness |
| [Tailscale](https://tailscale.com) | Private network for remote access |
| [mosh](https://mosh.org) | Stable SSH over mobile connections |
| [lazygit](https://github.com/jesseduffield/lazygit) | TUI git client |
| [ripgrep](https://github.com/BurntSushi/ripgrep) | Fast grep |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | Smart `cd` |

## Neovim keymaps (highlights)

| Key | Action |
|-----|--------|
| `-` | Open parent dir (oil.nvim) |
| `<leader>ff` | Find files (snacks) |
| `<leader>fg` | Grep (snacks) |
| `<leader>gg` | Neogit |
| `<leader>gd` | Diff view |
| `<Space>` | Leader key |
| `jk` / `kj` | Exit insert mode |
