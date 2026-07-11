# Spec: wezterm-hotkey-overlay

## ADDED Requirements

### Requirement: Hotkey overlay is invocable via LEADER ?

The WezTerm configuration SHALL bind `LEADER ?` to open an in-terminal overlay listing the mux leader keybindings.

#### Scenario: Opening the overlay

- **WHEN** the user presses the leader key (Ctrl+Space) followed by `?`
- **THEN** an overlay titled "WezTerm Mux Hotkeys" opens over the current pane

#### Scenario: Dismissing the overlay

- **WHEN** the overlay is open and the user presses Escape
- **THEN** the overlay closes without executing any action

### Requirement: Overlay lists every leader binding with key and description

The overlay SHALL display one entry per leader keybinding, showing the key and a human-readable description, and SHALL support fuzzy filtering by typing.

#### Scenario: All bindings listed

- **WHEN** the overlay is open
- **THEN** every binding defined with `mods = LEADER` in the configuration appears as an entry showing its key and description

#### Scenario: Fuzzy filtering

- **WHEN** the overlay is open and the user types "split"
- **THEN** the list narrows to entries whose labels fuzzy-match "split" (the horizontal and vertical split bindings)

### Requirement: Selecting an overlay entry executes its binding

The overlay SHALL execute the action of the selected entry in the pane the overlay was opened from.

#### Scenario: Executing an action from the overlay

- **WHEN** the user opens the overlay, selects the "Split horizontal" entry, and confirms with Enter
- **THEN** the current pane splits horizontally, exactly as if the user had pressed `LEADER \`

### Requirement: Bindings and overlay derive from a single source of truth

The leader keybindings in `config.keys` and the overlay entries SHALL both be generated from one shared data table, and all pre-existing leader bindings SHALL retain their exact key and action.

#### Scenario: No drift between bindings and overlay

- **WHEN** a leader binding is added to or removed from the shared table
- **THEN** both the active keybinding and its overlay entry appear or disappear together, with no second location to update

#### Scenario: Existing bindings unchanged

- **WHEN** the refactored configuration is loaded
- **THEN** every leader binding that existed before the change (splits, pane navigation, resize, zoom, close, tabs, rename, tab numbers, detach, copy mode) works with the same key and behavior as before
