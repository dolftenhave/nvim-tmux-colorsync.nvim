require("color")

---@class read_color_file
---@param path string A path to the nvim color file.
---@return TmuxColor[]? colors
local function read_color_file(path)
	local colors = {}
	local file = io.open(path, "r")
	local sep_eq = "(.+)="
	local sep_dq = '"(.*)"'

	if file ~= nil then
		for line in file:lines() do
			if line ~= nil and line.isspace() == false then
				if string.sub(line, 1, 1) ~= "#" then
					local tname = string.match(line, sep_eq)
					---@type TmuxColor
					local color = {
						name = tname,
						hex = string.match(line, sep_dq),
						default = tname,
					}
					table.insert(colors, color)
				end
			end
		end
		file:close()
	end

	return next(colors) == nil and nil or colors
end

---@class Write
local M = {}

--- Gets the tmux colors from the tmux color files.
---@class get_tmux_colors
---@param path string The path to the tmux color file.
---@return TmuxColor[]? colors table of colors.
function M.get_tmux_colors(path)
	if (vim.uv or vim.loop).fs_stat(path) then
		return read_color_file(vim.fs.abspath(path))
	else
		return nil
	end
end

return M
