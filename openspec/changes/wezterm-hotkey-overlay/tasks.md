# Tasks: WezTerm Mux Hotkey Overlay

## 1. Refactor bindings into a single source of truth

- [x] 1.1 Define a `mux_bindings` table in `wezterm.lua` with one `{ key, desc, action }` record per existing leader binding, preserving order and exact actions
- [x] 1.2 Generate `config.keys` by iterating `mux_bindings` with `mods = 'LEADER'`
- [x] 1.3 Diff the generated bindings against the original `config.keys` block to confirm no binding was dropped or altered

## 2. Implement the overlay

- [x] 2.1 Add a `hotkey_overlay()` function that builds `act.InputSelector` choices from `mux_bindings` with aligned key/description labels and fuzzy filtering enabled
- [x] 2.2 Wire the selector callback to execute the chosen binding via `window:perform_action`
- [x] 2.3 Add the `LEADER ?` entry (opening the overlay) to `mux_bindings` itself so it is self-documenting

## 3. Verify

- [x] 3.1 Syntax-check the config (`wezterm --config-file ... show-keys`) so a typo cannot break terminal startup
- [ ] 3.2 Manually verify in WezTerm: `LEADER ?` opens the overlay, fuzzy filter works, Escape dismisses, and selecting "Split horizontal" splits the pane
- [ ] 3.3 Spot-check that pre-existing bindings (e.g. `LEADER \`, `LEADER h`, `LEADER c`) still work
