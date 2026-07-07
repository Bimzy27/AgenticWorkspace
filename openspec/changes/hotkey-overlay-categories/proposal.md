# Proposal: Hotkey Overlay Categories (NVIM + Claude CLI sections)

## Why

The `LEADER ?` overlay only lists WezTerm mux bindings, but the daily workflow in this terminal spans three tools whose hotkeys are equally hard to memorize: WezTerm, Neovim, and the Claude Code CLI.
Extending the overlay into a single categorized cheatsheet makes all of them discoverable from one place, with fuzzy filtering across categories.

## What Changes

- Restructure the overlay's data model in `.config/wezterm/wezterm.lua` from a flat `mux_bindings` table into categorized sections, starting with three: `MUX`, `NVIM`, and `CLAUDE`.
- Render the category as a visible prefix on each overlay entry so entries group naturally and fuzzy search can filter by category name (e.g. typing `nvim` shows only that section).
- Add an `NVIM` section: a curated, reference-only list of the custom keymaps defined in `.config/nvim/lua/keymaps.lua` (leader keymaps, window navigation, line moves, etc.).
- Add a `CLAUDE` section: a curated, reference-only list of Claude Code CLI keyboard shortcuts (e.g. mode cycling, transcript, background, bash prefix).
- Reference-only entries (NVIM, CLAUDE) carry no WezTerm action; selecting one simply dismisses the overlay. MUX entries keep their current which-key behavior of executing the selected binding.
- Existing MUX keybindings, their keys, and their behavior are unchanged.

## Capabilities

### New Capabilities

<!-- None: this extends the existing overlay capability rather than introducing a new one. -->

### Modified Capabilities

- `wezterm-hotkey-overlay`: the overlay grows from a flat mux-only binding list to a categorized cheatsheet with sections, including reference-only entries that display but do not execute.
  Note: this capability's spec currently exists only as the delta in the archived-pending `wezterm-hotkey-overlay` change (it was never synced to `openspec/specs/`); this change's delta builds on that spec.

## Impact

- `.config/wezterm/wezterm.lua`: overlay data model and label generation change; `config.keys` generation must keep consuming only the MUX section.
- `.config/nvim/lua/keymaps.lua`: unchanged, but becomes the source the curated NVIM section mirrors. The two can drift; keeping them aligned is a documented maintenance point (design covers mitigation).
- No new dependencies: WezTerm built-ins only (`InputSelector`, `action_callback`).
