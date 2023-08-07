-- (field) Options.custom_view: {
--     hide: unknown,
--     is_valid: unknown,
--     on_close: unknown,
--     render: unknown,
--     scroll: unknown,
--     show: unknown,
-- }

local M = {}

local win
local buf

function M.hide()
  if win and vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_win_close(win, true)
  end
end

function M.show()
  if win and vim.api.nvim_win_is_valid(win) then return end

  buf = vim.api.nvim_create_buf(false, true)
  local config = {
    relative = "editor",
    width = 35,
    height = 10,
    row = vim.o.lines - 13,
    col = vim.o.columns,
    style = "minimal",
    border = "rounded",
    focusable = false,
    zindex = 1000,
  }
  win = vim.api.nvim_open_win(buf, false, config)
end

function M.is_valid()
  --vim.print("is_valid")
end

function M.scroll(...)
  --vim.print("scroll", ...)
end

function M.on_close(...)
  --vim.print("close", ...)
end

---@param items VisualMapping[]
function M.render(items)
  local wants_width = 35
  local wants_height = 10

  local lines = require("willothy.lines")

  ---@param mapping VisualMapping
  local process = function(mapping)
    local label = mapping.label
    local key = mapping.key

    return {
      { label, "WhichKeyDesc" },
      { ": ", "Normal" },
      { key, "WhichKeyValue" },
      len = vim.fn.strdisplaywidth(label) + vim.fn.strdisplaywidth(key) + 2,
    }
  end
  local text = vim.iter(items):map(process):totable()

  -- sort into rows and cols
  local cols = {}

  local col = 1
  local row = 1
  local width = 0
  for _, line in ipairs(text) do
    if width + line.len > wants_width then
      row = row + 1
      col = 1
      width = 0
    end

    if not cols[row] then cols[row] = {} end
    cols[row][col] = line
    col = col + 1
    width = width + line.len
  end

  -- translate to rows
  local rows = {}

  for _, col in ipairs(cols) do
    local row = {}
    for _, line in ipairs(col) do
      vim.list_extend(row, line)
    end
    table.insert(rows, row)
  end

  for i, row in ipairs(rows) do
    local line = lines:new(row)
    rows[i] = line:render()
  end

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(text, "\n"))
end

function M.show_cursor() end

function M.hide_cursor() end

return M
