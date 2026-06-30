local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.default_domain = 'WSL:Ubuntu'
config.window_close_confirmation = 'NeverPrompt'
config.skip_close_confirmation_for_processes_named = {
  'bash', 'sh', 'zsh', 'fish', 'tmux', 'nu',
  'cmd.exe', 'pwsh.exe', 'powershell.exe',
  'wsl.exe', 'wslhost.exe',
}

config.window_decorations = 'RESIZE'
config.window_padding = {
  left = "1cell",
  right = "1cell",
  top = "0.7cell",
  bottom = "0.7cell",
}

config.max_fps = 200
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
  saturation = 0.75,
  brightness = 0.5,
}

config.keys = {
  {
    key = 'c',
    mods = 'CTRL',
    action = wezterm.action_callback(function(window, pane)
      selection_text = window:get_selection_text_for_pane(pane)
      is_selection_active = string.len(selection_text) ~= 0
      if is_selection_active then
        window:perform_action(wezterm.action.CopyTo('ClipboardAndPrimarySelection'), pane)
      else
        window:perform_action(wezterm.action.SendKey{ key='c', mods='CTRL' }, pane)
      end
    end),
  },
  { key = 'v',          mods = 'CTRL',      action = wezterm.action { PasteFrom = 'Clipboard' } },
  { key = 'q',          mods = 'CTRL',      action = wezterm.action.QuitApplication },
  { key = 'w',          mods = 'CTRL|SHIFT',action = wezterm.action.CloseCurrentPane { confirm = false } },
  { key = '_',          mods = 'SHIFT|ALT', action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = '+',          mods = 'SHIFT|ALT', action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' } },
  -- ALT+Arrow to move between panes (cleaner than SHIFT+ALT)
  { key = 'LeftArrow',  mods = 'ALT',       action = wezterm.action.ActivatePaneDirection 'Left' },
  { key = 'RightArrow', mods = 'ALT',       action = wezterm.action.ActivatePaneDirection 'Right' },
  { key = 'UpArrow',    mods = 'ALT',       action = wezterm.action.ActivatePaneDirection 'Up' },
  { key = 'DownArrow',  mods = 'ALT',       action = wezterm.action.ActivatePaneDirection 'Down' },
  { key = 'phys:LeftBracket',  mods = 'CTRL|SHIFT', action = wezterm.action.ActivateTabRelative(-1) },
  { key = 'phys:RightBracket', mods = 'CTRL|SHIFT', action = wezterm.action.ActivateTabRelative(1) },
}

local scheme = wezterm.color.get_builtin_schemes()['Raycast_Dark']
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
      fg_color = '#6c6c6c',
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

return config