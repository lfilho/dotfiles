local wezterm = require("wezterm")
local lwl = wezterm.plugin.require("https://github.com/estin/lazy-workspace-layout?rev=master")
local M = {}

local send_command = function(pane, command)
  pane:send_text(command .. "\n")
end

local function setup_notes(_, pane)
  local editor_pane = pane

  send_command(editor_pane, "n")

  editor_pane:activate()
end

local function setup_dev2(_, pane)
  local editor_pane = pane
  local git_pane = pane:split({ direction = "Right", size = 0.3 })

  send_command(editor_pane, "v")
  send_command(git_pane, "gs")

  editor_pane:activate()
end

local function setup_dev3(_, pane)
  local editor_pane = pane
  local server_pane = editor_pane:split({ direction = "Right", size = 0.3 })
  local git_pane = server_pane:split({ direction = "Bottom" })

  send_command(editor_pane, "v")
  send_command(server_pane, "npm run dev")
  send_command(git_pane, "gs")

  editor_pane:activate()
end

local home = wezterm.home_dir
local workspaces = {
  {
    cwd = home
        .. "/Library/Containers/co.noteplan.NotePlan-setapp/Data/Library/Application Support/co.noteplan.NotePlan-setapp/Notes",
    label = "Notes",
    layout = setup_notes,
  },
  {
    cwd = home .. "/.yadr",
    label = "Dotfiles",
    layout = setup_dev2,
  },
  {
    cwd = home .. "/work/",
    label = "Work",
    layout = setup_dev3,
  },
  {
    cwd = home .. "/standalone/emscripts/gsheet-gantt",
    label = "Gantt",
    layout = setup_dev3,
  },
  {
    cwd = home .. "/standalone/emscripts/initiative-tracker",
    label = "Initiative Tracker",
    layout = setup_dev3,
  },
  {
    cwd = home,
    label = "default",
    layout = setup_dev2,
  },
}
lwl.init(workspaces)

M.select = lwl.bind

return M
