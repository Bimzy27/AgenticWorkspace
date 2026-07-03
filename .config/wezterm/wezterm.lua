local wezterm = require('wezterm')
local config = wezterm.config_builder()
local act = wezterm.action

local is_windows = wezterm.target_triple:find('windows') ~= nil
local is_linux = wezterm.target_triple:find('linux') ~= nil

-- Mux: persistent sessions survive GUI close (named pipe on Windows, socket on Linux).
-- The GUI auto-starts wezterm-mux-server on connect if it is not running; on Windows
-- the 'WezTermMuxServer' logon task (scripts/install-configs.ps1) also starts it.
config.unix_domains = { { name = 'main' } }
config.default_gui_startup_args = { 'connect', 'main' }

-- Launch fullscreen. 'gui-startup' only fires for plain `wezterm start`; when the GUI
-- launches via `connect` (default_gui_startup_args above) 'gui-attached' fires instead.
-- The is_full_screen guard prevents a double toggle when both events fire.
wezterm.on('gui-startup', function(cmd)
  local _, _, window = wezterm.mux.spawn_window(cmd or {})
  window:gui_window():toggle_fullscreen()
end)

wezterm.on('gui-attached', function()
  for _, window in ipairs(wezterm.mux.all_windows()) do
    local gui = window:gui_window()
    if gui and not gui:get_dimensions().is_full_screen then
      gui:toggle_fullscreen()
    end
  end
end)

-- Appearance: frameless single-window, no distractions
config.window_decorations = is_windows and 'INTEGRATED_BUTTONS|RESIZE' or 'NONE'
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.window_padding = { left = 2, right = 2, top = 2, bottom = 2 }

-- Font
config.font = wezterm.font('IosevkaTerm Nerd Font', { weight = 'Regular' })
config.font_size = is_windows and 12.0 or 14.0
config.line_height = 1.1

-- Color scheme
config.color_scheme = 'Catppuccin Mocha'

-- Performance
config.max_fps = 120
config.animation_fps = 60
config.front_end = 'WebGpu'

-- Inactive pane dimming
config.inactive_pane_hsb = {
  saturation = 0.8,
  brightness = 0.6,
}

-- Shell per platform
if is_windows then
  config.default_prog = { 'pwsh.exe', '-NoLogo' }
  config.window_background_opacity = 0.95
else
  config.default_prog = { '/bin/zsh' }
  config.window_background_opacity = 1.0
  config.enable_wayland = true
end

-- Scrollback
config.scrollback_lines = 10000

-- Leader key (Ctrl+a, like tmux)
config.leader = { key = 'Space', mods = 'CTRL', timeout_milliseconds = 1000 }

-- Leader bindings: single source of truth for config.keys AND the hotkey overlay.
-- Add/remove bindings here only; both the keybinding and its overlay entry follow.
local mux_bindings = {
  -- Pane splits
  { key = '\\', desc = 'Split horizontal', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = '-',  desc = 'Split vertical',   action = act.SplitVertical   { domain = 'CurrentPaneDomain' } },

  -- Pane navigation (vim-style)
  { key = 'h', desc = 'Focus pane left',  action = act.ActivatePaneDirection('Left') },
  { key = 'j', desc = 'Focus pane down',  action = act.ActivatePaneDirection('Down') },
  { key = 'k', desc = 'Focus pane up',    action = act.ActivatePaneDirection('Up') },
  { key = 'l', desc = 'Focus pane right', action = act.ActivatePaneDirection('Right') },

  -- Pane resize
  { key = 'H', desc = 'Resize pane left',  action = act.AdjustPaneSize { 'Left',  5 } },
  { key = 'J', desc = 'Resize pane down',  action = act.AdjustPaneSize { 'Down',  5 } },
  { key = 'K', desc = 'Resize pane up',    action = act.AdjustPaneSize { 'Up',    5 } },
  { key = 'L', desc = 'Resize pane right', action = act.AdjustPaneSize { 'Right', 5 } },

  -- Pane zoom / close
  { key = 'z', desc = 'Toggle pane zoom', action = act.TogglePaneZoomState },
  { key = 'x', desc = 'Close pane',       action = act.CloseCurrentPane { confirm = true } },

  -- Tabs
  { key = 'c', desc = 'New tab',      action = act.SpawnTab 'CurrentPaneDomain' },
  { key = 'w', desc = 'Close tab',    action = act.CloseCurrentTab { confirm = true } },
  { key = 'n', desc = 'Next tab',     action = act.ActivateTabRelative(1) },
  { key = 'p', desc = 'Previous tab', action = act.ActivateTabRelative(-1) },
  { key = ',', desc = 'Rename tab',   action = act.PromptInputLine {
    description = 'Rename tab',
    action = wezterm.action_callback(function(window, _, line)
      if line then window:active_tab():set_title(line) end
    end),
  }},

  -- Jump to tab by number
  { key = '1', desc = 'Go to tab 1', action = act.ActivateTab(0) },
  { key = '2', desc = 'Go to tab 2', action = act.ActivateTab(1) },
  { key = '3', desc = 'Go to tab 3', action = act.ActivateTab(2) },
  { key = '4', desc = 'Go to tab 4', action = act.ActivateTab(3) },
  { key = '5', desc = 'Go to tab 5', action = act.ActivateTab(4) },

  -- Mux: detach session
  { key = 'd', desc = 'Detach session', action = act.DetachDomain 'CurrentPaneDomain' },

  -- Copy mode
  { key = '[', desc = 'Copy mode', action = act.ActivateCopyMode },

  -- Hotkey overlay (action assigned below, after hotkey_overlay is defined,
  -- so the overlay's choice list includes this entry too)
  { key = '?', desc = 'Show this hotkey overlay' },
}

-- Hotkey overlay (LEADER ?): fuzzy-searchable cheatsheet of every leader binding.
-- Selecting an entry executes it, which-key style.
local function hotkey_overlay()
  local choices = {}
  for i, b in ipairs(mux_bindings) do
    table.insert(choices, {
      id = tostring(i),
      label = string.format('LEADER %-4s %s', b.key, b.desc),
    })
  end
  return act.InputSelector {
    title = 'WezTerm Mux Hotkeys',
    choices = choices,
    fuzzy = true,
    fuzzy_description = 'Filter hotkeys: ',
    action = wezterm.action_callback(function(window, pane, id)
      if id then
        window:perform_action(mux_bindings[tonumber(id)].action, pane)
      end
    end),
  }
end

mux_bindings[#mux_bindings].action = hotkey_overlay()

config.keys = {}
for _, b in ipairs(mux_bindings) do
  table.insert(config.keys, { key = b.key, mods = 'LEADER', action = b.action })
end

-- Copy mode: vi keys
config.key_tables = {
  copy_mode = {
    { key = 'h',      mods = 'NONE', action = act.CopyMode('MoveLeft') },
    { key = 'j',      mods = 'NONE', action = act.CopyMode('MoveDown') },
    { key = 'k',      mods = 'NONE', action = act.CopyMode('MoveUp') },
    { key = 'l',      mods = 'NONE', action = act.CopyMode('MoveRight') },
    { key = 'Escape', mods = 'NONE', action = act.CopyMode('Close') },
    { key = 'q',      mods = 'NONE', action = act.CopyMode('Close') },
  },
}

return config
