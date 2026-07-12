-- mux-sessions: persist wezterm-mux-server session state across reboots.
--
-- The mux server holds all windows/tabs/panes in memory, so a reboot loses
-- them even though the WezTermMuxServer logon task restarts the process.
-- This module snapshots the mux layout (workspaces, window cell sizes, tabs,
-- pane splits, pane working directories, titles, zoom/active flags) to a JSON
-- file on a timer, and rebuilds it on 'mux-startup' when a fresh mux server
-- boots, spawning each window at its saved size.
--
-- It is self-contained on purpose: the canonical plugin for this
-- (MLFlexer/resurrect.wezterm) was archived in May 2026 with "use a fork"
-- guidance, and it targets the GUI process rather than wezterm-mux-server,
-- which is where the state actually lives in this setup.
--
-- Scope: layout + cwd only. Running programs cannot survive a reboot; each
-- restored pane starts the default shell in the saved working directory.
--
-- Everything is gated behind 'mux-startup', which only fires inside
-- wezterm-mux-server, so the GUI process (whose mirrored panes cannot report
-- foreground-process cwd) never saves and never restores.

local wezterm = require('wezterm')

local M = {}

-- Test hooks: both are overridable via environment so an isolated mux server
-- can be exercised end to end without touching the real state file.
M.state_file = os.getenv('WEZTERM_MUX_STATE_FILE')
  or (wezterm.home_dir .. '/.local/share/wezterm/mux-state.json')
M.save_interval = tonumber(os.getenv('WEZTERM_MUX_SAVE_INTERVAL') or '') or 60

local function log_error(msg)
  wezterm.log_error('mux-sessions: ' .. msg)
end

-- ── Capture ───────────────────────────────────────────────────────────────

-- Best-effort cwd for a pane. Prefers the foreground process cwd (works for
-- local panes on Windows, where shells do not emit OSC 7), falling back to
-- get_current_working_dir which returns a file:// URI string on this wezterm
-- version and a Url object on newer ones.
local function pane_cwd(pane)
  local ok, info = pcall(function()
    return pane:get_foreground_process_info()
  end)
  if ok and info and info.cwd and #info.cwd > 0 then
    -- Strip the Windows extended-length prefix if present.
    return (info.cwd:gsub('^\\\\%?\\', ''))
  end

  local uri = pane:get_current_working_dir()
  if type(uri) == 'userdata' then
    return uri.file_path
  end
  if type(uri) == 'string' then
    local path = uri:gsub('^file://[^/]*', '')
    path = path:gsub('%%(%x%x)', function(hex)
      return string.char(tonumber(hex, 16))
    end)
    -- file:///C:/foo -> C:/foo
    if path:match('^/%a:') then
      path = path:sub(2)
    end
    if #path > 0 then
      return path
    end
  end
  return nil
end

-- Snapshot the current mux state into a plain table.
function M.capture()
  local windows = {}
  for _, win in ipairs(wezterm.mux.all_windows()) do
    local tabs = {}
    for _, tab_info in ipairs(win:tabs_with_info()) do
      local panes = {}
      for _, p in ipairs(tab_info.tab:panes_with_info()) do
        panes[#panes + 1] = {
          left = p.left,
          top = p.top,
          width = p.width,
          height = p.height,
          is_active = p.is_active,
          is_zoomed = p.is_zoomed,
          cwd = pane_cwd(p.pane),
        }
      end
      if #panes > 0 then
        tabs[#tabs + 1] = {
          -- get_title returns only explicitly set titles (LEADER , rename);
          -- auto-computed titles come back empty and are not restored.
          title = tab_info.tab:get_title(),
          is_active = tab_info.is_active,
          panes = panes,
        }
      end
    end
    if #tabs > 0 then
      windows[#windows + 1] = {
        workspace = win:get_workspace(),
        tabs = tabs,
      }
    end
  end
  return { version = 1, saved_at = os.time(), windows = windows }
end

-- ── Persistence ───────────────────────────────────────────────────────────

function M.load()
  local f = io.open(M.state_file, 'r')
  if not f then
    return nil
  end
  local body = f:read('*a')
  f:close()
  local ok, state = pcall(wezterm.json_parse, body)
  if not ok or type(state) ~= 'table' or type(state.windows) ~= 'table' then
    log_error('ignoring unreadable state file ' .. M.state_file)
    return nil
  end
  return state
end

function M.save()
  local state = M.capture()

  -- Teardown guard: during system shutdown panes die before the mux server
  -- does. A snapshot with zero windows must not clobber the last good state,
  -- or the reboot-persistence this module exists for is lost. The rare cost
  -- is that deliberately closing every window resurrects the old layout
  -- after the next reboot.
  if #state.windows == 0 then
    local previous = M.load()
    if previous and #previous.windows > 0 then
      return
    end
  end

  local json = wezterm.json_encode(state)
  local tmp = M.state_file .. '.tmp'
  local f, err = io.open(tmp, 'w')
  if not f then
    log_error('cannot write ' .. tmp .. ': ' .. tostring(err))
    return
  end
  f:write(json)
  f:close()
  -- Near-atomic replace; os.rename cannot overwrite on Windows.
  os.remove(M.state_file)
  local ok, rename_err = os.rename(tmp, M.state_file)
  if not ok then
    log_error('cannot replace ' .. M.state_file .. ': ' .. tostring(rename_err))
  end
end

-- ── Layout reconstruction ─────────────────────────────────────────────────
--
-- panes_with_info gives each pane's cell rectangle (left/top/width/height).
-- WezTerm layouts are built from binary splits, so the rectangles form a
-- guillotine partition: some full-height vertical cut or full-width
-- horizontal cut always exists. Recursively find a cut, split the pane list
-- in two, and rebuild the same tree with pane:split() calls.

local function extent(panes)
  local x0, y0, x1, y1 = math.huge, math.huge, -math.huge, -math.huge
  for _, p in ipairs(panes) do
    x0 = math.min(x0, p.left)
    y0 = math.min(y0, p.top)
    x1 = math.max(x1, p.left + p.width)
    y1 = math.max(y1, p.top + p.height)
  end
  return x0, y0, x1, y1
end

-- Find the lowest coordinate > min where no pane straddles the cut line.
-- axis 'x' scans pane.left/width, axis 'y' scans pane.top/height.
local function find_cut(panes, axis)
  local lo = axis == 'x' and 'left' or 'top'
  local len = axis == 'x' and 'width' or 'height'
  local x0 = math.huge
  for _, p in ipairs(panes) do
    x0 = math.min(x0, p[lo])
  end
  local candidates = {}
  for _, p in ipairs(panes) do
    if p[lo] > x0 then
      candidates[#candidates + 1] = p[lo]
    end
  end
  table.sort(candidates)
  for _, cut in ipairs(candidates) do
    local valid = true
    for _, p in ipairs(panes) do
      if p[lo] < cut and p[lo] + p[len] > cut then
        valid = false
        break
      end
    end
    if valid then
      return cut
    end
  end
  return nil
end

local function partition(panes, axis, cut)
  local lo = axis == 'x' and 'left' or 'top'
  local a, b = {}, {}
  for _, p in ipairs(panes) do
    if p[lo] < cut then
      a[#a + 1] = p
    else
      b[#b + 1] = p
    end
  end
  return a, b
end

-- Build a binary split tree: leaves are {pane = <saved pane>}, inner nodes
-- are {axis, ratio, a, b} where ratio is the fraction of the node's area
-- given to subtree b (the newly split-off pane).
local function build_tree(panes)
  if #panes == 1 then
    return { pane = panes[1] }
  end
  for _, axis in ipairs({ 'x', 'y' }) do
    local cut = find_cut(panes, axis)
    if cut then
      local a, b = partition(panes, axis, cut)
      local x0, y0, x1, y1 = extent(panes)
      local ratio
      if axis == 'x' then
        ratio = (x1 - cut) / (x1 - x0)
      else
        ratio = (y1 - cut) / (y1 - y0)
      end
      return {
        axis = axis,
        ratio = ratio,
        a = build_tree(a),
        b = build_tree(b),
      }
    end
  end
  -- Non-guillotine geometry (possible after heavy manual resizing). Degrade
  -- to an even split chain so every pane and cwd still comes back.
  log_error('no clean cut for ' .. #panes .. ' panes; using fallback layout')
  local rest = {}
  for i = 2, #panes do
    rest[#rest + 1] = panes[i]
  end
  return {
    axis = 'x',
    ratio = (#panes - 1) / #panes,
    a = { pane = panes[1] },
    b = build_tree(rest),
  }
end

local function first_leaf(node)
  while not node.pane do
    node = node.a
  end
  return node.pane
end

-- Recreate the split tree inside mux_pane. Splits off subtree b first (its
-- ratio is relative to the undivided node area), then subdivides each half.
-- Annotates each leaf with the live mux pane as .mux.
local function realize(node, mux_pane)
  if node.pane then
    node.pane.mux = mux_pane
    return
  end
  local new_pane = mux_pane:split {
    direction = node.axis == 'x' and 'Right' or 'Bottom',
    size = node.ratio,
    cwd = first_leaf(node.b).cwd,
  }
  realize(node.a, mux_pane)
  realize(node.b, new_pane)
end

local function realize_tab(tab, initial_pane, saved_tab, tree)
  realize(tree, initial_pane)
  if saved_tab.title and #saved_tab.title > 0 then
    tab:set_title(saved_tab.title)
  end
  local active_leaf, zoomed_leaf
  for _, saved_pane in ipairs(saved_tab.panes) do
    if saved_pane.mux then
      if saved_pane.is_active then
        active_leaf = saved_pane
      end
      if saved_pane.is_zoomed then
        zoomed_leaf = saved_pane
      end
    end
  end
  -- tab:set_zoomed zooms whichever pane is active, so when zoom and focus
  -- disagree the zoomed pane wins: it is what was on screen at save time.
  if zoomed_leaf then
    zoomed_leaf.mux:activate()
    tab:set_zoomed(true)
  elseif active_leaf then
    active_leaf.mux:activate()
  end
end

-- ── Restore ───────────────────────────────────────────────────────────────

-- Saved cell size of a window, taken from the extent of its first tab's
-- pane rectangles (every tab in a window shares the window size). Returns
-- nil when the saved geometry is unusable so the caller can fall back to
-- the default size.
local function saved_window_size(saved_win)
  local x0, y0, x1, y1 = extent(saved_win.tabs[1].panes)
  local width, height = x1 - x0, y1 - y0
  if width > 0 and height > 0 and width < math.huge and height < math.huge then
    return width, height
  end
  return nil, nil
end

-- Rebuild all saved windows. Returns true if anything was restored.
function M.restore()
  local state = M.load()
  if not state or #state.windows == 0 then
    return false
  end
  for _, saved_win in ipairs(state.windows) do
    local first = saved_win.tabs[1]
    local first_tree = build_tree(first.panes)
    -- Spawn at the saved cell size rather than the 80x24 default. Without
    -- this the whole layout is rebuilt tiny, and the resize to fullscreen
    -- on the next GUI attach is exactly the path where mux size sync is
    -- unreliable (wezterm/wezterm#2351), which shows up as mis-rendered
    -- panes when the window opens.
    local width, height = saved_window_size(saved_win)
    local tab, pane, win = wezterm.mux.spawn_window {
      workspace = saved_win.workspace,
      cwd = first_leaf(first_tree).cwd,
      width = width,
      height = height,
    }
    realize_tab(tab, pane, first, first_tree)
    local active_tab = first.is_active and tab or nil
    for i = 2, #saved_win.tabs do
      local saved_tab = saved_win.tabs[i]
      local tree = build_tree(saved_tab.panes)
      local new_tab, new_pane = win:spawn_tab { cwd = first_leaf(tree).cwd }
      realize_tab(new_tab, new_pane, saved_tab, tree)
      if saved_tab.is_active then
        active_tab = new_tab
      end
    end
    if active_tab then
      active_tab:activate()
    end
  end
  wezterm.log_info(string.format(
    'mux-sessions: restored %d window(s) from %s', #state.windows, M.state_file))
  return true
end

-- ── Wiring ────────────────────────────────────────────────────────────────

local function schedule_save()
  wezterm.time.call_after(M.save_interval, function()
    local ok, err = pcall(M.save)
    if not ok then
      log_error('save failed: ' .. tostring(err))
    end
    schedule_save()
  end)
end

-- Only the mux server owns real local panes (the GUI's mirrored panes cannot
-- report foreground-process cwd), so saving is gated on the process name.
local function is_mux_server()
  local ok, info = pcall(function()
    return wezterm.procinfo.get_info_for_pid(wezterm.procinfo.pid())
  end)
  return ok and info ~= nil and info.name ~= nil
    and info.name:find('mux%-server') ~= nil
end

-- Call from wezterm.lua at config top level.
--
-- Timer placement is deliberate and empirically verified on wezterm 20240203:
-- inside wezterm-mux-server, wezterm.time.call_after never fires when
-- scheduled from an event handler (e.g. 'mux-startup'), but works when
-- scheduled during config evaluation. The config is evaluated more than once
-- (startup evaluates it twice; every reload evaluates it again) and only the
-- most recent evaluation's Lua context stays live: discarded contexts take
-- their scheduled timers with them. Scheduling unconditionally here therefore
-- yields exactly one active save chain, and config reloads replace it rather
-- than stacking duplicates.
function M.enable()
  wezterm.on('mux-startup', function()
    local ok, err = pcall(M.restore)
    if not ok then
      log_error('restore failed: ' .. tostring(err))
    end
    if not M._save_armed then
      log_error('periodic save is not armed; is_mux_server() misdetected')
    end
  end)
  if is_mux_server() then
    M._save_armed = true
    schedule_save()
  end
end

return M
