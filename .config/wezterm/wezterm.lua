local wezterm = require('wezterm')
local config = wezterm.config_builder()
local act = wezterm.action

local is_windows = wezterm.target_triple:find('windows') ~= nil
local is_linux = wezterm.target_triple:find('linux') ~= nil

-- Mux: persistent sessions survive GUI close (named pipe on Windows, socket on Linux)
-- Run `wezterm-mux-server --daemonize` first, then uncomment to enable persistent sessions.
-- config.unix_domains = { { name = 'main' } }
-- config.default_gui_startup_args = { 'connect', 'main' }

-- Launch fullscreen
wezterm.on('gui-startup', function(cmd)
  local _, _, window = wezterm.mux.spawn_window(cmd or {})
  window:gui_window():toggle_fullscreen()
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

config.keys = {
  -- Pane splits
  { key = '\\', mods = 'LEADER', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = '-',  mods = 'LEADER', action = act.SplitVertical   { domain = 'CurrentPaneDomain' } },

  -- Pane navigation (vim-style)
  { key = 'h', mods = 'LEADER', action = act.ActivatePaneDirection('Left') },
  { key = 'j', mods = 'LEADER', action = act.ActivatePaneDirection('Down') },
  { key = 'k', mods = 'LEADER', action = act.ActivatePaneDirection('Up') },
  { key = 'l', mods = 'LEADER', action = act.ActivatePaneDirection('Right') },

  -- Pane resize
  { key = 'H', mods = 'LEADER', action = act.AdjustPaneSize { 'Left',  5 } },
  { key = 'J', mods = 'LEADER', action = act.AdjustPaneSize { 'Down',  5 } },
  { key = 'K', mods = 'LEADER', action = act.AdjustPaneSize { 'Up',    5 } },
  { key = 'L', mods = 'LEADER', action = act.AdjustPaneSize { 'Right', 5 } },

  -- Pane zoom / close
  { key = 'z', mods = 'LEADER', action = act.TogglePaneZoomState },
  { key = 'x', mods = 'LEADER', action = act.CloseCurrentPane { confirm = true } },

  -- Tabs
  { key = 'c', mods = 'LEADER', action = act.SpawnTab 'CurrentPaneDomain' },
  { key = 'w', mods = 'LEADER', action = act.CloseCurrentTab { confirm = true } },
  { key = 'n', mods = 'LEADER', action = act.ActivateTabRelative(1) },
  { key = 'p', mods = 'LEADER', action = act.ActivateTabRelative(-1) },
  { key = ',', mods = 'LEADER', action = act.PromptInputLine {
    description = 'Rename tab',
    action = wezterm.action_callback(function(window, _, line)
      if line then window:active_tab():set_title(line) end
    end),
  }},

  -- Jump to tab by number
  { key = '1', mods = 'LEADER', action = act.ActivateTab(0) },
  { key = '2', mods = 'LEADER', action = act.ActivateTab(1) },
  { key = '3', mods = 'LEADER', action = act.ActivateTab(2) },
  { key = '4', mods = 'LEADER', action = act.ActivateTab(3) },
  { key = '5', mods = 'LEADER', action = act.ActivateTab(4) },

  -- Mux: detach session
  { key = 'd', mods = 'LEADER', action = act.DetachDomain 'CurrentPaneDomain' },

  -- Copy mode
  { key = '[', mods = 'LEADER', action = act.ActivateCopyMode },
}

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
