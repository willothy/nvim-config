-- Attempting to build an MVP cursorword plugin using only Treesitter and Lua,
-- no matchadd or vim regex. Very WIP.
local buf = 0
local win = 0

local cursor = vim.api.nvim_win_get_cursor(win)
local curs_point = {
  row = cursor[1] - 1,
  col = cursor[2],
}

local node = vim.treesitter.get_node({
  bufnr = buf,
  pos = {
    curs_point.row,
    curs_point.col,
  },
  lang = vim.bo[buf].ft,
})

local point_in_range = function(pt, range)
  return pt.row >= range.start.row
    and pt.row <= range.end_.row
    and pt.col >= range.start.col
    and pt.col < range.end_.col
end

local ts_range = function(...)
  local range = { ... }
  return {
    start = {
      row = range[1],
      col = range[2],
    },
    end_ = {
      row = range[3],
      col = range[4],
    },
  }
end

local curr = node
local last
while curr do
  if curr == nil or curr:child_count() == 0 then
    break
  end

  last = curr
  curr = curr:child(0)
  while curr and not point_in_range(curs_point, ts_range(curr:range())) do
    curr = curr:next_sibling()
  end
end

---@param n TSNode?
local node_info = function(n)
  if not n then
    return
  end
  -- vim.treesitter.is_in_node_range()
  local start_row, start_col, end_row, end_col = n:range()
  return {
    type = n:type(),
    start = { row = start_row, col = start_col },
    end_ = { row = end_row, col = end_col },
    text = vim.api.nvim_buf_get_text(
      buf,
      start_row,
      start_col,
      end_row,
      end_col,
      {}
    ),
  }
end

vim.print(node_info(curr))
