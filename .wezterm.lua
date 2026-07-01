local wezterm = require 'wezterm'
local config = wezterm.config_builder()

local is_windows = wezterm.target_triple:find('windows') ~= nil
local is_mac = wezterm.target_triple:find('apple') ~= nil
local is_linux = wezterm.target_triple:find('linux') ~= nil
local mod = is_mac and 'CMD' or 'CTRL'

if is_windows then
  config.default_domain = 'WSL:Ubuntu'
elseif is_mac then
  config.default_prog = { os.getenv('SHELL') or '/bin/zsh', '-l' }
end

config.window_close_confirmation = 'NeverPrompt'
config.skip_close_confirmation_for_processes_named = {
  'bash', 'sh', 'zsh', 'fish', 'tmux', 'nu',
  'cmd.exe', 'pwsh.exe', 'powershell.exe',
  'wsl.exe', 'wslhost.exe',
}

if is_mac then
  config.window_decorations = 'INTEGRATED_BUTTONS|RESIZE'
else
  config.window_decorations = 'RESIZE'
end

config.window_padding = {
  left = "1cell",
  right = "1cell",
  top = "0.7cell",
  bottom = "0.7cell",
}

config.max_fps = 240
config.animation_fps = 60
config.scrollback_lines = 10000

-- config.color_scheme = 'Github Dark (Gogh)'
-- config.color_scheme = 'Rosé Pine Moon (base16)'
-- config.color_scheme = 'Rosé Pine (base16)'
config.color_scheme = 'Raycast_Dark'

config.font = wezterm.font 'FantasqueSansM Nerd Font'
config.font_size = 15.0
config.bold_brightens_ansi_colors = false
config.foreground_text_hsb = {
  hue = 1.0,
  saturation = 1.1,
  brightness = 1.0,
}

config.default_cursor_style = 'SteadyBar'

config.inactive_pane_hsb = {
  saturation = 0.74,
  brightness = 0.47,
}

config.keys = {
  {
    key = 'c',
    mods = mod,
    action = wezterm.action_callback(function(window, pane)
      local selection_text = window:get_selection_text_for_pane(pane)
      local is_selection_active = string.len(selection_text) ~= 0
      if is_selection_active then
        window:perform_action(wezterm.action.CopyTo('ClipboardAndPrimarySelection'), pane)
      elseif is_mac then
        -- Nothing selected + CMD+C on mac: just copy is a no-op, do nothing
      else
        window:perform_action(wezterm.action.SendKey{ key = 'c', mods = 'CTRL' }, pane)
      end
    end),
  },
  { key = 'v', mods = mod, action = wezterm.action { PasteFrom = 'Clipboard' } },

  { key = 'q', mods = mod, action = wezterm.action.QuitApplication },
  { key = 'w', mods = mod, action = wezterm.action.CloseCurrentPane { confirm = false } },

  { key = 't', mods = mod, action = wezterm.action.SpawnCommandInNewTab { domain = 'CurrentPaneDomain', cwd = '~' } },
  { key = 'g', mods = mod, action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 'G', mods = mod .. '|SHIFT', action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' } },
  { key = '_', mods = 'SHIFT|ALT', action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = '+', mods = 'SHIFT|ALT', action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' } },

  { key = 'LeftArrow',  mods = 'ALT', action = wezterm.action.ActivatePaneDirection 'Left' },
  { key = 'RightArrow', mods = 'ALT', action = wezterm.action.ActivatePaneDirection 'Right' },
  { key = 'UpArrow',    mods = 'ALT', action = wezterm.action.ActivatePaneDirection 'Up' },
  { key = 'DownArrow',  mods = 'ALT', action = wezterm.action.ActivatePaneDirection 'Down' },

  { key = 'phys:LeftBracket',  mods = mod .. '|SHIFT', action = wezterm.action.ActivateTabRelative(-1) },
  { key = 'phys:RightBracket', mods = mod .. '|SHIFT', action = wezterm.action.ActivateTabRelative(1) },

 
}

if is_windows then
  table.insert(config.keys, {
    key = 'p',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.SpawnCommandInNewTab {
      domain = { DomainName = 'local' },
      args = { 'powershell.exe', '-NoExit' },
    },
  })
  table.insert(config.keys, {
    key = 'p',
    mods = 'CTRL|SHIFT|ALT',
    action = wezterm.action.SpawnCommandInNewTab {
      domain = { DomainName = 'local' },
      args = {
        'powershell.exe', '-NoExit', '-Command',
        'Start-Process powershell -Verb RunAs', -- elevated
      },
    },
  })
end

local scheme = wezterm.color.get_builtin_schemes()[config.color_scheme]
local bg = scheme.background
local fg = scheme.foreground
config.colors = {
  tab_bar = {
    background = bg,

    active_tab = {
      bg_color = bg,
      fg_color = fg,
      intensity = 'Bold',
      italic = true,
    },

    inactive_tab = {
      bg_color = bg,
      fg_color = '#707070',
    },

    inactive_tab_hover = {
      bg_color = bg,
      fg_color = fg,
    },

    new_tab = {
      bg_color = bg,
      fg_color = '#6c6c6c',
    },

    new_tab_hover = {
      bg_color = bg,
      fg_color = fg,
    },

    inactive_tab_edge = bg,
  },
}

wezterm.on('format-tab-title', function(tab)
  local title = tab.active_pane.title

  if not title or title == '' or title:find('wslhost') then
    local proc = tab.active_pane.foreground_process_name
    if proc then
      proc = proc:match("([^/\\]+)$")
      if proc and not proc:find('wslhost') then
        title = proc
      else
        title = 'shell'
      end
    end
  end

  return '   ' .. title .. '   '
end)

config.use_fancy_tab_bar = true
config.tab_bar_at_bottom = false
config.hide_tab_bar_if_only_one_tab = false
config.show_tab_index_in_tab_bar = false
config.show_tabs_in_tab_bar = true
config.show_new_tab_button_in_tab_bar = false
config.tab_max_width = 40
config.window_frame = {
  active_titlebar_bg = bg,
  inactive_titlebar_bg = bg,
  active_titlebar_fg = fg,
  inactive_titlebar_fg = '#6c6c6c',
  active_titlebar_border_bottom = bg,
  inactive_titlebar_border_bottom = bg,
  font = wezterm.font 'FantasqueSansM Nerd Font',
  font_size = 13.0,
}

wezterm.on('window-config-reloaded', function(window, pane)
  -- sometimes global hotkeys in Windows might conflict and cause
  -- WezTerm to lose focus on boot, so we re-focus just in case
  window:focus()
end)

return config