require("color")

---@class write_colors
---@param path string The path to the tmux color file.
---@param colors TmuxColor[] A list of tmux colors.
---@param key key The color to write.
---@return boolean sucess True if the file was written without issue.
local write_colors = function(path, colors, key)
	path = vim.fs.abspath(path)

	local sucess = false

	local file = io.write(path)

	if file ~= nil then
		for i, color in ipairs(colors) do
			file:write(color:line(key))
		end
		sucess = true
	end
	io.close(file)
	return sucess
end

local M = {}

---@class write_colors
---@param path string The path of the tmux color file.
---@param colors TmuxColor[] A list of tmux colors.
---@return boolean sucess True if the file was written.
M.write_colors = function(path, colors)
	if (vim.uv or vim.loop).fs_stat then
		return write_colors(path, colors, "hex")
	else
		return false
	end
end

---@class set_color
---@param index integer The index of the color in the colors table.
---@param color string The hex value.
---@param colors TmuxColor[] A list of tmux colors.
---@return TmuxColor colors The updated list of colors.
M.set_color = function(index, color, colors)
	colors[index].hex = color
	return colors
end

---@class write_default_colors
---@param path string The path of the tmux color conf file.
---@param colors TmuxColor[] A list of tmux colors.
---@return boolean sucess True if the write was successful.
M.write_default_colors = function(path, colors)
	if (vim.uv or vim.loop).fs_stat then
		return write_colors(path, colors, "default")
	else
		return false
	end
end

return M
