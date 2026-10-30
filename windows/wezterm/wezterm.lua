local wezterm = require("wezterm")
local mux = wezterm.mux

local function setup_work_workspace()
	local ws_name = "work"

	local tab1, _, window = mux.spawn_window({
		workspace = ws_name,
		args = { "wsl.exe", "-d", "archlinux", "--cd", "~/Repos/https", "nvim" },
	})
	tab1:set_title("HTTPS Repo")

	local tab2, _, _ = window:spawn_tab({
		args = { "wsl.exe", "-d", "archlinux", "--cd", "~/", "nvim" },
	})
	tab2:set_title("Root Editor")

	tab1:activate()
end

wezterm.on("gui-startup", function(_)
	setup_work_workspace()
end)

return {
	default_prog = { "wsl.exe", "-d", "archlinux", "--cd", "~/" },

	font = wezterm.font("JetBrainsMono Nerd Font", { weight = "Medium" }),
	font_size = 10.5,

	initial_cols = 160,
	initial_rows = 40,

	window_padding = {
		left = 8,
		right = 8,
		top = 8,
		bottom = 8,
	},

	color_scheme = "rose-pine-dawn",

	cursor_blink_rate = 0,
	window_close_confirmation = "NeverPrompt",
	window_decorations = "RESIZE",

	keys = {
		{
			key = "w",
			mods = "CTRL|SHIFT",
			action = wezterm.action.CloseCurrentTab({ confirm = false }),
		},
		{
			key = "s",
			mods = "CTRL|SHIFT",
			action = wezterm.action.ShowLauncherArgs({
				flags = "FUZZY|WORKSPACES",
			}),
		},
	},

	launch_menu = {
		{
			label = "PowerShell 7 (pwsh)",
			args = { "pwsh.exe" },
		},
	},

	colors = {
		selection_fg = "#575279",
		selection_bg = "#c4a7e7",

		tab_bar = {
			background = "#faf4ed",

			active_tab = {
				bg_color = "#faf4ed",
				fg_color = "#575279",
				intensity = "Bold",
				underline = "None",
				italic = true,
			},

			inactive_tab = {
				bg_color = "#f2e9e1",
				fg_color = "#9893a5",
			},

			inactive_tab_hover = {
				bg_color = "#dfdad9",
				fg_color = "#575279",
			},

			new_tab = {
				bg_color = "#faf4ed",
				fg_color = "#9893a5",
			},
			new_tab_hover = {
				bg_color = "#dfdad9",
				fg_color = "#575279",
			},
		},
	},

	window_frame = {
		font = wezterm.font("CaskaydiaCove Nerd Font Propo"),
		font_size = 10.5,

		active_titlebar_bg = "#f2e9e1",
		active_titlebar_fg = "#575279",
		active_titlebar_border_bottom = "#cec9c7",

		inactive_titlebar_bg = "#dfdad9",
		inactive_titlebar_fg = "#9893a5",

		button_fg = "#575279",
		button_bg = "#f2e9e1",
		button_hover_fg = "#575279",
		button_hover_bg = "#cec9c7",
	},
	inactive_pane_hsb = {
		brightness = 1.0,
	},
	use_fancy_tab_bar = false,
	tab_bar_at_bottom = true,
}
