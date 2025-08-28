# nvim-tmux-colorsync

![Preview](https://i.imgur.com/I7Qq2FA.gif)

This plugin aims to make it easier to match tmux colors after nvim state changes. The plugin makes trivial use of au groups, sending tmux commands to the shell when the event is triggered.

- [Installation](#Installation)
- [Config](#Config)
- [Planned Features](#Planned-Features)

## Installation

### Requirements 

- **TMUX** 

### Plugin Manager

Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
"dolftenhave/nvim-tmux-colorsync"
```

## Config

### Example Configs

This is an explanation of what each setting does. If you want to see a working example, please see the [Example Implementation](#Example-Implementation).

**Important!** Many of these settings are default. You do not need to set them unless you want to change them. 

```lua
require{
    "dolftenhave/nvim-tmux-colorsync",
    config = function()
            local color_sync = require("nvim-tmux-colorsync").setup({
                -- Set this to false if you do not want the plugin to load.
                -- (default = true).
                enabled = true,

                -- Enabling verbose will print out any au groups that are created and/or erros that are encountered.
                -- This is VERY useful when setting up the plugin.
                -- (default = false).
                verbose = true,

                -- The path to your tmux.conf file. This will be used to with the source command when exiting neovim to restore default visuals.
                -- (default = "~/.tmux.conf").
                conf_path = "~/.tmux.conf",

                -- If true 'tmux source conf_path' will be called when leaving neovim.
                -- (default = true).
                reset_on_leave = true,

                -- This is the global default highlight field selected from the neovim highlight group.
                -- Change this if you prefer a different color.
                -- (default = "bg").
                default_hl_field = "bg",

                -- This is the command that will be send the proceeding arguments to tmux.
                -- Only change this if you have 'tmux' aliased to something else.
                -- (default = tmux, or tmux -g when verbose is disabled.)
                cmd = "tmux",

                -- Here you specify the tmux components that you want to change when an event is triggered. The command will call the field (if set) or name, followed by the arguments. Place the The colors will be placed anywhere you put a < > tag in your arg string.
                --
                -- name - The name of your component. This is used as the field if tmux_field is left out.
                -- tmux_field - (optional). If set, this is used instead of name as the tmux field.
                -- args - The arguments following the tmux field. Any < > will be replaced with the highlight group color.
                ui_components = {
                    ["name"] = {
                        tmux_field = "field",
                        args = "args",
                    },
                    ["window-status-current-format"] = {
                        -- For readability it is recomended to place a word between the < and > tages.
                        args = "#[bg=<COLOR>,fg=${BG}][#I#[fg=${GRAY}]:#[fg=${BG}]#W]",
                    },
                },

                -- These options are used when creating the nvim au commands. Some are optional.
                -- vimEvents - A list of neovim events that will trigges the color change if the pattern matches.
                -- cmd - The tmux command that will be called when after 'tmux'. This should be the sames as the command in your tmux.conf.
                -- pattern - The au command pattern. Default = *.
                -- hl_group_name - (optional if you set a manual hex color). The name of the neovim highligh group. The color will be taken from here based on the hl_field when syncing with tmux.
                -- hex_color - (optional if using a hl_group_name). This hex color will be used enstead of a highlight group if the event is triggered.
                -- component_names - This is a list of components that will be updated when the event is triggerd. The names should match the names of the components in the ui_components list.
                -- hl_field - (optional) The highlight field in the neovim highlight group that the color will be copied from. If this is not set, the default will be used.
                triggers = {
                    vimEvents = { "event 1", "...", "event n" },
                    cmd = "set-option",
                    pattern = "*",
                    hl_group_name = "vim_bg",
                    hex_color = "#123456",
                    component_names = { "name", "window-status-current-format" },
                    hl_field = "bg",
                },
            })
        end,
}
```

### Example-Implementation
 
This example updates parts of the status bar every time neovim changes mode, like in the preview video at the top. It sources it's colors from lualine components.

```lua
local color_sync = require("nvim-tmux-colorsync").setup({
			-- Prints out any au groups and errors.
			-- VERY useful when setting up for the first time.
			verbose = true,

			-- setting custom path to the tmux.conf file
			conf_path = "~/.config/tmux/tmux.conf",

			-- These are the arguments that will be run after the tmux command.
			ui_components = {
				-- You can use the name of the tmux field or use your own name and manually set the field.
				-- This may be useful if you want to change different areas based on different events.
				["status-left"] = {
					args = "#[bg=<Any Name Works Here.>, fg=${BG}] [#S] #[bg=${GRAY},fg=${FG}] pane: #P ",
				},
				["right_status_bar"] = {
					tmux_field = "status-right",
					args = "#[bg=${GRAY},fg=${FG}] #{pane_current_path} #[bg=<COLOR>, fg=${BG}] #h ",
				},
			},

			triggers = {
				{
					vimEvents = { "ModeChanged" },
					-- The event will be accepted if the pattern matches.
					-- In this case Visual or visual block mode.
					pattern = "*:[vV]*",
					-- Set option is the tmux command that will be called before the field.
					-- (tmux set-option status-left....)
					cmd = "set-option",
					-- The list of components that will be updated.
					component_names = { "right_status_bar", "status-left" },
					-- The neovim highlight group where the color will be taken from.
					hl_group_name = "lualine_a_visual",
					-- The highlight field decides what color of the highlight group will be copied.
					-- (bg, fg, .. ect)
					hl_field = "bg",
				},
				{
					vimEvents = { "ModeChanged" },
					pattern = "*:[nN]*",
					cmd = "set-option",
					component_names = { "right_status_bar", "status-left" },
					hl_group_name = "lualine_a_normal",
				},
				{
					vimEvents = { "ModeChanged" },
					pattern = "*:[cC]*",
					cmd = "set-option",
					component_names = { "right_status_bar", "status-left" },
					hl_group_name = "lualine_a_command",
				},
				{
					vimEvents = { "ModeChanged" },
					pattern = "*:[iI]*",
					cmd = "set-option",
					component_names = { "right_status_bar", "status-left" },
					hl_group_name = "lualine_a_insert",
				},
				{
					vimEvents = { "ModeChanged" },
					pattern = "*:[rR]*",
					cmd = "set-option",
					component_names = { "right_status_bar", "status-left" },
					hl_group_name = "lualine_a_replace",
				},
			},
		})
```
## Planned-Features

- Live updating of tmux accent colours to math nvim (eg. when changing modes in nvim).
