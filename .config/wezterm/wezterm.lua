local wezterm = require('wezterm')
local config = wezterm.config_builder()

local is_windows = wezterm.target_triple:find('windows') ~= nil
local is_linux = wezterm.target_triple:find('linux') ~= nil

-- Appearance: frameless single-window, no distractions
config.window_decorations = is_windows and 'INTEGRATED_BUTTONS|RESIZE' or 'NONE'
config.enable_tab_bar = false
config.window_padding = { left = 2, right = 2, top = 2, bottom = 2 }

-- Font
config.font = wezterm.font('IosevkaTerm Nerd Font', { weight = 'Regular' })
config.font_size = is_windows and 12.0 or 14.0
config.line_height = 1.1

-- Color scheme
config.color_scheme = 'Tokyo Night'

-- Performance
config.max_fps = 120
config.animation_fps = 60
config.front_end = 'WebGpu'

-- Inactive pane dimming (helps with tmux split focus)
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

-- Keys: pass everything through to tmux
config.keys = {
  -- Disable WezTerm's own tab/pane bindings so tmux handles them
  { key = 't', mods = 'CTRL|SHIFT', action = wezterm.action.DisableDefaultAssignment },
  { key = 'w', mods = 'CTRL|SHIFT', action = wezterm.action.DisableDefaultAssignment },
}

-- Copy mode uses vi keys
config.key_tables = {
  copy_mode = {
    { key = 'h', mods = 'NONE', action = wezterm.action.CopyMode('MoveLeft') },
    { key = 'j', mods = 'NONE', action = wezterm.action.CopyMode('MoveDown') },
    { key = 'k', mods = 'NONE', action = wezterm.action.CopyMode('MoveUp') },
    { key = 'l', mods = 'NONE', action = wezterm.action.CopyMode('MoveRight') },
    { key = 'Escape', mods = 'NONE', action = wezterm.action.CopyMode('Close') },
    { key = 'q', mods = 'NONE', action = wezterm.action.CopyMode('Close') },
  },
}

return config
