# Proposal: WezTerm Mux Hotkey Overlay

## Why

The WezTerm mux hotkeys (leader-based pane, tab, and copy-mode bindings) are only discoverable by reading `wezterm.lua`, which slows down day-to-day use and makes it hard to build muscle memory.
A native in-terminal cheatsheet overlay makes every binding discoverable without leaving the terminal.

## What Changes

- Refactor the leader keybindings in `.config/wezterm/wezterm.lua` into a single data table (key, description, action) that serves as the single source of truth.
- Generate `config.keys` from that table so the real bindings and the cheatsheet can never drift apart.
- Add a hotkey overlay using WezTerm's native `InputSelector` that lists every leader binding with its description, supports fuzzy filtering, and executes the selected action (which-key style).
- Bind the overlay to `LEADER ?`, following the tmux `prefix ?` convention for listing keybindings.

## Capabilities

### New Capabilities

- `wezterm-hotkey-overlay`: An in-terminal overlay listing all WezTerm mux leader bindings, invocable via `LEADER ?`, with fuzzy filtering and the ability to execute the selected binding.

### Modified Capabilities

<!-- None: existing leader bindings keep identical keys and behavior; only their definition site is refactored. -->

## Impact

- `.config/wezterm/wezterm.lua`: keybinding section refactored into a data-driven table plus overlay generation. No changes to existing key assignments or behavior.
- No new dependencies: uses WezTerm built-ins only (`InputSelector`, `action_callback`).
