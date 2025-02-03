local wezterm = require("wezterm")
local lwl = wezterm.plugin.require("https://github.com/estin/lazy-workspace-layout?rev=master")
local M = {}

local send_command = function(pane, command)
  pane:send_text(command .. "\n")
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

  -- Run specific commands in each pane
  send_command(editor_pane, "v")
  send_command(server_pane, "npm run dev")
  send_command(git_pane, "gs")

  editor_pane:activate()
end

local home = wezterm.home_dir
local workspaces = {
  {
    cwd = home .. "/.yadr",
    label = "Dotfiles",
    layout = function(window, pane, ws)
      setup_dev2(window, pane)
    end,
  },
  {
    cwd = home .. "/work/",
    label = "Work",
    layout = function(_, pane, _)
      setup_dev3(window, pane)
    end,
  },
}
lwl.init(workspaces)

M.select = lwl.bind

return M

-- local M = {}
-- local wezterm = require("wezterm")
-- local action = wezterm.action
--
-- local home = wezterm.home_dir
-- local workspaces = {
--   { id = home .. "/.yadr", label = "Dotfiles" },
--   { id = home .. "/work/", label = "Gantt" },
--   { id = home .. "/notes", label = "Notes" },
--   { id = home, label = "default" },
-- }
--
-- local function setup_dev2(window, pane)
--   local editor_pane = pane
--   -- Split pane vertically
--   local git_pane = pane:split({ direction = "Right" })
--
--   -- Run specific commands in each pane
--   editor_pane:send_text("v\n")
--   git_pane:send_text("gs\n")
-- end
--
-- local function setup_dev3(window, pane)
--   local editor_pane = pane
--   -- Split pane vertically
--   local server_pane = pane:split({ direction = "Right" })
--   local git_pane = pane:split({ direction = "Bottom" })
--
--   -- Run specific commands in each pane
--   editor_pane:send_text("v\n")
--   server_pane:send_text("npm run dev\n")
--   git_pane:send_text("gs\n")
-- end
--
-- local bootstrap_workspace_layout = function(window, pane)
--   local current_workspace = window:active_workspace()
--   local has_only_pane = #window:active_tab():panes() == 1
--
--   if has_only_pane then
--     if current_workspace == "Dotfiles" then
--       wezterm.log_info("Setting up dev2")
--       setup_dev2(window, pane)
--     elseif current_workspace == "Gantt" then
--       wezterm.log_info("Setting up dev3")
--       setup_dev3(window, pane)
--     end
--   end
-- end
--
-- M.select = function(window, pane)
--   window:perform_action(
--     action.InputSelector({
--       action = wezterm.action_callback(function(inner_window, inner_pane, id, label)
--         if id and label then
--           inner_window:perform_action(
--             action.SwitchToWorkspace({
--               name = label,
--               spawn = {
--                 label = "Workspace: " .. label,
--                 cwd = id,
--               },
--             }),
--             inner_pane
--           )
--
--           wezterm.sleep_ms(1000)
--           bootstrap_workspace_layout(window, pane)
--         end
--       end),
--       title = "Choose Workspace",
--       choices = workspaces,
--       fuzzy = true,
--       fuzzy_description = "Find or create a workspace: ",
--     }),
--     pane
--   )
-- end
--
-- return M
