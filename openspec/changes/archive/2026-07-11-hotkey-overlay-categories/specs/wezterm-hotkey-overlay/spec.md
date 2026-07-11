# Spec delta: wezterm-hotkey-overlay (hotkey-overlay-categories)

## ADDED Requirements

### Requirement: Overlay entries are grouped into labeled categories

Every overlay entry SHALL carry a visible category label, with entries of the same category listed contiguously.
The initial categories are `MUX` (WezTerm leader bindings), `NVIM` (Neovim keymaps), and `CLAUDE` (Claude Code CLI shortcuts).

#### Scenario: Categories are visible and grouped

- **WHEN** the overlay is open with no filter text
- **THEN** each entry's label starts with its category tag (e.g. `[MUX]`, `[NVIM]`, `[CLAUDE]`) and each category's entries appear as one contiguous block

#### Scenario: Filtering by category name

- **WHEN** the overlay is open and the user types `nvim`
- **THEN** the list narrows to the NVIM section's entries

### Requirement: Overlay includes an NVIM reference section

The overlay SHALL include a curated NVIM category listing the custom keymaps defined in `.config/nvim/lua/keymaps.lua`, each shown with its key chord and a human-readable description.

#### Scenario: NVIM keymaps listed

- **WHEN** the overlay is open
- **THEN** the NVIM section lists the custom keymaps (escape chords, window navigation and resize, line moves, quickfix, buffer navigation, splits, diagnostics) with their key chords

### Requirement: Overlay includes a CLAUDE CLI reference section

The overlay SHALL include a curated CLAUDE category listing default Claude Code CLI keyboard shortcuts relevant to daily use, each shown with its key and a human-readable description.

#### Scenario: Claude Code shortcuts listed

- **WHEN** the overlay is open
- **THEN** the CLAUDE section lists default Claude Code CLI shortcuts (e.g. mode cycling, interrupt, bash prefix) with their keys

### Requirement: Reference entries are display-only

Entries in reference categories (NVIM, CLAUDE) SHALL NOT carry a WezTerm action; selecting one SHALL close the overlay without executing anything or modifying any pane.

#### Scenario: Selecting a reference entry

- **WHEN** the user opens the overlay, highlights an NVIM or CLAUDE entry, and confirms with Enter
- **THEN** the overlay closes and no action is performed in the terminal

## MODIFIED Requirements

### Requirement: Hotkey overlay is invocable via LEADER ?

The WezTerm configuration SHALL bind `LEADER ?` to open an in-terminal overlay listing the categorized hotkeys.

#### Scenario: Opening the overlay

- **WHEN** the user presses the leader key (Ctrl+Space) followed by `?`
- **THEN** an overlay titled "Hotkeys" opens over the current pane

#### Scenario: Dismissing the overlay

- **WHEN** the overlay is open and the user presses Escape
- **THEN** the overlay closes without executing any action

### Requirement: Overlay lists every leader binding with key and description

The overlay SHALL display one entry per leader keybinding under the `MUX` category, showing the key and a human-readable description, and SHALL support fuzzy filtering by typing.
Only `MUX` entries SHALL be used to generate `config.keys`; reference categories MUST NOT produce keybindings.

#### Scenario: All bindings listed

- **WHEN** the overlay is open
- **THEN** every binding defined with `mods = LEADER` in the configuration appears as a `[MUX]` entry showing its key and description

#### Scenario: Fuzzy filtering

- **WHEN** the overlay is open and the user types "split"
- **THEN** the list narrows to entries whose labels fuzzy-match "split", regardless of category

#### Scenario: Reference sections do not create keybindings

- **WHEN** the configuration is loaded
- **THEN** `config.keys` contains exactly one binding per MUX table entry and none for NVIM or CLAUDE entries
