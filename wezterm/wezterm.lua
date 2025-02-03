local wezterm = require("wezterm")
local action = wezterm.action

local config = wezterm.config_builder()

--------------
-- Appeareance
--------------
config.color_scheme = "Catppuccin Mocha"

config.inactive_pane_hsb = {
	saturation = 0.5,
	brightness = 0.3,
}

-- config.background = {
-- 	{
-- 		source = {
-- 			File = "/Users/lgonzaga/.yadr/img/terminal-bg-fallout.jpg",
-- 			-- File = "/Users/lgonzaga/.yadr/img/pipboy-green-small.jpg",
-- 			-- File = "/Users/lgonzaga/.yadr/img/pipboy-color.png",
-- 		},
-- 		horizontal_align = "Right",
-- 		vertical_align = "Bottom",
-- 		width = "100%",
-- 		height = "Contain",
-- 		repeat_x = "Mirror",
-- 		repeat_y = "NoRepeat",
-- 	},
-- }

config.font = wezterm.font("FiraCode Nerd Font Mono")
config.font_size = 16.0
config.cell_width = 0.93

---------------
-- Key bindings
---------------
config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }

-- Show which key table is active in the status area
wezterm.on("update-right-status", function(window, pane)
	local name = window:active_key_table()
	if name then
		name = "Key table: " .. name
	end
	window:set_right_status(name or "")
end)

config.key_tables = {
	resize_pane = {
		{ key = "h", action = action.AdjustPaneSize({ "Left", 1 }) },
		{ key = "l", action = action.AdjustPaneSize({ "Right", 1 }) },
		{ key = "k", action = action.AdjustPaneSize({ "Up", 1 }) },
		{ key = "j", action = action.AdjustPaneSize({ "Down", 1 }) },

		-- Cancel the mode by pressing escape
		{ key = "Escape", action = "PopKeyTable" },
	},
}

config.keys = {
	-- LEADER followed by 'r' will put us in resize-pane mode until we cancel that mode.
	{
		key = "r",
		mods = "LEADER",
		action = action.ActivateKeyTable({
			name = "resize_pane",
			one_shot = false,
		}),
	},
	{
		key = "w",
		mods = "CMD",
		action = wezterm.action.CloseCurrentPane({ confirm = true }),
	},

	-- Key bindings for Vim-like navigation
	-- Split panes
	{ key = "d", mods = "SUPER", action = action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "d", mods = "SUPER|SHIFT", action = action.SplitVertical({ domain = "CurrentPaneDomain" }) },

	-- Navigate between panes
	{ key = "h", mods = "CTRL", action = action.ActivatePaneDirection("Left") },
	{ key = "j", mods = "CTRL", action = action.ActivatePaneDirection("Down") },
	{ key = "k", mods = "CTRL", action = action.ActivatePaneDirection("Up") },
	{ key = "l", mods = "CTRL", action = action.ActivatePaneDirection("Right") },

	-- Resize panes
	{ key = "h", mods = "OPT", action = action.AdjustPaneSize({ "Left", 1 }) },
	{ key = "j", mods = "OPT", action = action.AdjustPaneSize({ "Right", 1 }) },
	{ key = "k", mods = "OPT", action = action.AdjustPaneSize({ "Up", 1 }) },
	{ key = "l", mods = "OPT", action = action.AdjustPaneSize({ "Down", 1 }) },

	-- Send "CTRL-A" to the terminal when pressing CTRL-A, CTRL-A
	{
		key = "a",
		mods = "LEADER|CTRL",
		action = wezterm.action.SendKey({ key = "a", mods = "CTRL" }),
	},
}

-- Smart splits with NeoVim:
local smart_splits = wezterm.plugin.require("https://github.com/mrjones2014/smart-splits.nvim")
smart_splits.apply_to_config(config, {
	modifiers = {
		move = "CTRL", -- modifier to use for pane movement, e.g. CTRL+h to move left
		resize = "OPT", -- modifier to use for pane resize, e.g. META+h to resize to the left
	},
	-- log level to use: info, warn, error
	log_level = "info",
})

return config
