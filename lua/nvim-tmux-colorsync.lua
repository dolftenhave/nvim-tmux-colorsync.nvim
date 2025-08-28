---@class ColorSync
local M = {}

---@class UiComponent
---@field tmux_field string?
---@field args string

---@class Trigger
---@field vimEvents string[]
---@field cmd string?
---@field pattern? string
---@field hl_group_name string?
---@field hex_color string?
---@field component_names string[]?
---@field hl_field string?
local Trigger = {
	pattern = "*",
}

---@class NTCSConfig
---@field enabled boolean?
---@field verbose boolean?
---@field triggers Trigger[]?
---@field cmd string?
---@field ui_components {[string]: UiComponent}?
---@field default_hl_field string?
local default_config = {
	enabled = true,
	verbose = false,
	conf_path = "~/.tmux.conf",
	default_hl_field = "bg",
	reset_on_leave = true,
}

---@type NTCSConfig
M.config = vim.deepcopy(default_config)

M.log = function(...)
	if M.config.verbose == false then
		return
	end
	print("ColorSync: ", ...)
end

M.log_err = function(...)
	M.log("Error!", ...)
end

M.to_hex = function(n)
	local b = n % 256
	local g = ((n - b) / 256) % 256
	local r = ((n - b) / 256 ^ 2) - g / 256
	return string.format("#%02X%02X%02X", r, g, b)
end

---@param trigger Trigger
M.try_get_color = function(trigger)
	if trigger.hl_group_name == nil then
		M.log_err("try_get_color: hl_group_name in Trigger ", trigger.vimEvents("is null or empty"))
		return
	end

	local cl_map = vim.api.nvim_get_hl(0, { name = trigger.hl_group_name })

	if next(cl_map) == nil then
		M.log_err("try_get_color: hl_group_name", trigger.hl_group_name, "may not exist.")
		return
	end

	if not trigger.hl_field then
		trigger.hl_field = M.config.default_hl_field
	end
	trigger.hex_color = M.to_hex(cl_map[trigger.hl_field])
end

---@param name string
---@return string?
M.try_get_component = function(name)
	if not name then
		M.log_err("No component name")
		return nil
	end

	local component = M.config.ui_components[name]
	if not component then
		M.log_err("component", name, "does not exist")
		return nil
	end
	local field = component.tmux_field and component.tmux_field or name
	return field .. " " .. '"' .. component.args .. '"'
end

M.create_au_commands = function()
	for _, trigger in ipairs(M.config.triggers) do
		if not trigger.hex_color then
			M.try_get_color(trigger)
		end
		for _, c_name in ipairs(trigger.component_names) do
			local component = M.try_get_component(c_name)
			if component and trigger.hex_color then
				local cmd = M.config.cmd .. trigger.cmd .. " " .. string.gsub(component, "<.->", trigger.hex_color)
				M.log("Creating aucmd:", "Pattern=", trigger.pattern, "cmd=", cmd)
				vim.api.nvim_create_autocmd(trigger.vimEvents, {
					pattern = trigger.pattern,
					callback = function()
						vim.fn.jobstart(cmd)
					end,
				})
			else
				M.log_err("Component", c.name, "may not exist")
			end
		end
	end
end

M.on_quit = function()
	vim.api.nvim_create_autocmd({ "QuitPre" }, {
		pattern = "*",
		callback = function()
			vim.fn.jobstart("tmux source " .. M.config.conf_path)
		end,
	})
end

M.setup = function(config)
	M.log("Starting config")
	if config == nil then
		M.log_err("Config is nil. Exiting.")
		return
	end

	M.config = vim.tbl_deep_extend("force", M.config, config or {})

	if not M.config.enabled then
		M.log("enabled=", M.config.enabled, "  Exiting.")
		return
	end

	if next(M.config.triggers) == nil then
		M.log_err("No triggers found. Exiting.")
		return
	end

	if next(M.config.ui_components) == nil then
		M.log_err("No ui componenents found. Exiting.")
		return
	end

	if M.config.cmd == nil then
		M.config.cmd = M.config.verbose and "tmux " or "tmux -g "
	end

	M.config.conf_path = vim.fs.abspath(M.config.conf_path)
	M.on_quit()
	M.create_au_commands()
	M.log("Done!")
end

return M
