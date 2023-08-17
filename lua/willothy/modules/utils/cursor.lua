local M = {}

local noice = require("noice.util.hacks")
local prev_cursor

function M.hide_cursor()
  prev_cursor = noice._guicursor
  noice._guicursor = nil
end

function M.show_cursor()
  noice._guicursor = prev_cursor
  prev_cursor = nil
end

return M
