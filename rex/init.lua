local home = os.getenv("HOME")
local float_servers = true
local minimize_servers = true

local function read(file)
  local f = io.open(home .. "/.dotfiles/" .. file)
  if not f then return {} end
  local data = rex.json.decode(f:read("*a"))
  f:close()
  return data or {}
end

local projects = read("workspaces.json")
for name, p in pairs(read("workspaces.local.json")) do projects[name] = p end

local function panes(rows, i)
  i = i or 1
  local label, dir, cmd = unpack(rows[i])
  local pane = rex.layout.block{
    flavor = "com.superlogical.terminal.shell",
    label = label,
    options = { cwd = dir:gsub("^~", home), initial_input = cmd and cmd .. "\n" },
  }
  if i == #rows then return pane end
  return rex.layout.horizontal(1 / (#rows - i + 1), pane, panes(rows, i + 1))
end

for name, p in pairs(projects) do
  rex.action{
    name = "project_" .. name:lower():gsub("%W", "_"),
    title = "Open Project: " .. name,
    run = function()
      for _, s in ipairs(rex.call("session.list").sessions) do
        if s.label == name then return rex.client.queue("session.select", { session_id = s.session_id }) end
      end
      local tabs = { { window_label = "agents", layout = panes(p.agents) } }
      if not float_servers then table.insert(tabs, 1, { window_label = "servers", layout = panes(p.servers) }) end
      local s, err = rex.call("session.create", { label = name, initial_windows = tabs })
      if not s then error(err, 0) end
      if float_servers then
        rex.call("session.attach", { session_id = s.session_id })
        for i, row in ipairs(p.servers) do
          local layer = rex.call("session.new_layer", { session_id = s.session_id, layout = panes({ row }),
            bounds = { 0.6, 0.05 + (i - 1) * 0.3, 0.38, 0.25 } })
          if minimize_servers and layer then
            rex.call("session.set_layer_state",
              { session_id = s.session_id, layer_id = layer.layer_id, state = "minimized" })
          end
        end
      end
      rex.client.queue("session.select", { session_id = s.session_id })
    end,
  }
end

rex.bind("cmd+g", "pane.split.right")
rex.bind("cmd+shift+g", "pane.split.down")
rex.bind("alt+shift+-", "pane.split.right")
rex.bind("alt+shift+=", "pane.split.down")
rex.bind("cmd+shift+m", "pane.minimize_all_floating")
rex.bind("cmd+alt+m", "pane.minimize_floating")

for _, dir in ipairs { "left", "right", "up", "down" } do
  rex.bind("cmd+" .. dir, "pane.focus", { direction = dir })
  rex.bind("alt+shift+" .. dir, "pane.resize", { direction = dir, amount = 3 })
end
