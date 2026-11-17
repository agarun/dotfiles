local ok, workspaces = pcall(require, "rex-workspaces")
if ok then workspaces.setup{} end

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
