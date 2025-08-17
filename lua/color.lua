local M = {}

---@class Color
---@field hex string The hex value of the color.
---@field destination_name string The name of the color that will be updated in the .conf file
---@field hl_group_name string The the highlight group name of the color in vim.
---@field event string The name of the event that when triggered, updates the color in tmux.
local Color = {}

return M
