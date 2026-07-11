# Tasks: hotkey-overlay-categories

## 1. Restructure overlay data model

- [x] 1.1 In `.config/wezterm/wezterm.lua`, add a `reference_sections` table (`{ name, entries = { { key, desc } } }`) alongside the existing `mux_bindings` table; leave `config.keys` generation reading `mux_bindings` only
- [x] 1.2 Rework `hotkey_overlay()` to build choices section by section: MUX from `mux_bindings` with ids `mux:<index>`, then each reference section with ids `ref:<section>:<index>`
- [x] 1.3 Add the category tag as a fixed-width bracketed label prefix (`[MUX]`, `[NVIM]`, `[CLAUDE]`) and widen the key column to fit chords like `<leader>sv`
- [x] 1.4 Update the selector callback to execute `mux_bindings[i].action` only for `mux:` ids and return without side effects otherwise

## 2. Populate reference sections

- [x] 2.1 Add the NVIM section mirroring the custom keymaps in `.config/nvim/lua/keymaps.lua` (escape chords, window nav/resize, line moves, centered scroll, paste-keep-register, quickfix, buffers, save, splits, diagnostics), noting leader = Space
- [x] 2.2 Add cross-reference comments in both `wezterm.lua` (NVIM section) and `keymaps.lua` pointing at each other so edits prompt keeping them aligned
- [x] 2.3 Add the CLAUDE section with default Claude Code CLI shortcuts (mode cycling, interrupt, bash `!` prefix, transcript, background, history), verified against current Claude Code docs (note: the docs no longer list a `#` memory prefix, so it is omitted)

## 3. Verify

- [x] 3.1 Run `wezterm show-keys` and confirm `config.keys` still contains exactly one binding per MUX entry (including `SHIFT|LEADER ?`) and nothing from the reference sections
- [x] 3.2 In WezTerm, open `LEADER ?` and confirm: categories render grouped with aligned columns; typing `nvim` filters to the NVIM section; selecting a MUX entry (e.g. Split horizontal) executes it; selecting a reference entry dismisses with no effect
