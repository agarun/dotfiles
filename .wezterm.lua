local wezterm = require 'wezterm'
local config = wezterm.config_builder()
config.default_domain = 'WSL:Ubuntu'
config.window_close_confirmation = 'NeverPrompt'
config.skip_close_confirmation_for_processes_named = {
  'bash',
  'sh',
  'zsh',
  'fish',
  'tmux',
  'nu',
  'cmd.exe',
  'pwsh.exe',
  'powershell.exe',
  'wsl.exe',
  'wslhost.exe',
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
  {
    key = 'v',
    mods = 'CTRL',
    action = wezterm.action { PasteFrom = 'Clipboard' }
  },
  {
    key = 'q',
    mods = 'CTRL',
    action = wezterm.action.QuitApplication
  },
  -- Close current pane without confirmation
  {
    key = 'w',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.CloseCurrentPane { confirm = false },
  },
  -- This will create a new split and run your default program inside it
  {
    key = '_',
    mods = 'SHIFT|ALT',
    action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
  },
  {
    key = '+',
    mods = 'SHIFT|ALT',
    action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
  },
  {
    key = 'LeftArrow',
    mods = 'SHIFT|ALT',
    action = wezterm.action.ActivatePaneDirection 'Left',
  },
  {
    key = 'RightArrow',
    mods = 'SHIFT|ALT',
    action = wezterm.action.ActivatePaneDirection 'Right',
  },
  {
    key = 'UpArrow',
    mods = 'SHIFT|ALT',
    action = wezterm.action.ActivatePaneDirection 'Up',
  },
  {
    key = 'DownArrow',
    mods = 'SHIFT|ALT',
    action = wezterm.action.ActivatePaneDirection 'Down',
  },
}
config.font_size = 15.0
config.bold_brightens_ansi_colors = "BrightAndBold"
config.window_decorations = "RESIZE"
config.foreground_text_hsb = {
  hue = 1.0,
  saturation = 1.1,
  brightness = 1.5,
}
config.inactive_pane_hsb = {
  saturation = 0.75,
  brightness = 0.5,
}
return config