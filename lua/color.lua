---@class Colors
local M = {}

---@class Color
---@field hex string? The hex value of the color.
---@field destination_name string The name of the color that will be updated in the colors.conf file
M.Color = {}

---@class TmuxColor
---@field hex string The hex value of the color.
---@field default string The value of the color when it was first read.
---@field name string The name of the color that will be updated in the colors.conf file.
M.TmuxColor = {}

---@class VimColor
---@field name string The index of the TmuxColor in the colors array.
---@field hex string The color of the highlight group name or custom color.
---@field hl_group_name string The the highlight group name of the color in vim.
---@field event string The name of the event that when triggered, updates the color in tmux.
M.VimColor = {}

return M
