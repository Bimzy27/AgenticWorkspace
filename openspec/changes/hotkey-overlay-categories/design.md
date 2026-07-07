# Design: Hotkey Overlay Categories

## Context

The `LEADER ?` overlay (`.config/wezterm/wezterm.lua`) is built from a single flat `mux_bindings` table of `{ key, desc, action }` records.
That table is the single source of truth: it generates both `config.keys` and the `InputSelector` choice list, and the selector callback executes the chosen entry's action.
The new NVIM and CLAUDE sections are fundamentally different: WezTerm cannot execute a Neovim keymap or a Claude Code CLI shortcut, so those entries are reference-only.
The design must add categories without weakening the executable-and-generated guarantee the MUX section already has.

## Goals / Non-Goals

**Goals:**

- Overlay entries are grouped into visible categories: `MUX`, `NVIM`, `CLAUDE`.
- Typing a category name in the fuzzy filter narrows the list to that section.
- MUX entries keep their which-key behavior (selecting executes the binding); `config.keys` is still generated only from the MUX table.
- NVIM and CLAUDE entries display key + description; selecting one dismisses the overlay without side effects.

**Non-Goals:**

- Auto-parsing `.config/nvim/lua/keymaps.lua` to generate the NVIM section (brittle regex over Lua source; curated list instead).
- Making reference entries executable (e.g. injecting keys into the pane); out of scope and surprising.
- Documenting exhaustive tool defaults (stock vim motions, every Claude Code shortcut); each section is a curated high-value list.
- Changing any existing MUX key assignment.

## Decisions

1. **Keep `mux_bindings` as-is; add a separate `reference_sections` table** of `{ name, entries = { { key, desc } } }` for NVIM and CLAUDE, rather than folding everything into one categorized mega-table.
   `config.keys` generation stays untouched and structurally cannot pick up reference entries.
   Alternative considered: one unified sections table with an `executable` flag per section - rejected because it makes the `config.keys` loop depend on filtering logic to stay correct.

2. **Category appears as a fixed-width bracketed prefix in each label**, e.g. `[MUX]   LEADER \  Split horizontal` / `[NVIM]  <C-h>     Focus window left`.
   `InputSelector` has no native section headers; a label prefix both groups visually (list is built section by section) and makes categories fuzzy-filterable, since the filter matches on the whole label.
   The key column widens from `%-4s` to fit NVIM chords like `<leader>sv`.

3. **Entry ids become namespaced strings: `mux:<index>` for executable entries, `ref:<section>:<index>` for reference entries.**
   The callback executes `mux_bindings[i].action` only for `mux:` ids and otherwise just returns (InputSelector closes itself).
   Alternative considered: omitting ids on reference entries - rejected because a nil id is indistinguishable from the user cancelling, which makes the callback's intent murky.

4. **NVIM section mirrors the custom keymaps in `.config/nvim/lua/keymaps.lua`** (escape chords, window nav/resize, line moves, quickfix, buffers, splits, diagnostics, leader = Space noted in the section).
   Curated, not generated; a cross-reference comment goes in both files so edits to one prompt updating the other.

5. **CLAUDE section lists Claude Code CLI defaults** relevant to daily use (Shift+Tab mode cycling, Esc interrupt, Ctrl+B background, `!` bash prefix, `#` memory, Ctrl+R transcript, etc.), sourced from Claude Code docs at implementation time.
   No `~/.claude/keybindings.json` exists on this machine, so defaults are the correct source.

## Risks / Trade-offs

- [Curated NVIM list drifts from `keymaps.lua`] → Cross-reference comments in both files; the overlay section is small and skimmable next to the keymap file in review.
- [Longer key column pads every MUX label wider than today] → Cosmetic only; alignment is computed in one `string.format` spec, single place to tune.
- [~50 entries makes the unfiltered list tall] → Acceptable: fuzzy filter is the primary navigation, and sections are contiguous so scanning stays easy.
- [Claude Code shortcuts change across CLI releases] → The section documents stable, long-standing defaults; treat updates like any other dotfiles tweak.

## Migration Plan

Single-file edit to `wezterm.lua` (plus a comment line in `keymaps.lua`).
WezTerm reloads config on save; rollback is `git checkout` of the file.

## Open Questions

None.
