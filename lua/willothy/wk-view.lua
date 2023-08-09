-- (field) Options.custom_view: {
--     hide: unknown,
--     is_valid: unknown,
--     on_close: unknown,
--     render: unknown,
--     scroll: unknown,
--     show: unknown,
-- }

local M = {}

M.options = {
  show_keys = false,
  show_help = false,
}

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
    border = "single",
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
function M.render(items, trail)
  local wants_width = 35
  local wants_height = 10

  local lines = require("willothy.lines")

  ---@param mapping VisualMapping
  local process = function(mapping)
    local label = mapping.label
    local key = mapping.key

    local len = vim.fn.strdisplaywidth(label) + vim.fn.strdisplaywidth(key) + 2
    return {
      { key, "WhichKey" },
      { ": ", "WhichKeySeparator" },
      {
        label,
        mapping.group and "WhichKeyGroup" or "WhichKeyDesc",
      },
      len = len,
    }
  end
  local ns = vim.api.nvim_create_namespace("wk_custom_view")
  local max_len = 0
  local text = vim.iter(items):map(process):map(function(l)
    max_len = math.max(max_len, l.len)
    l.len = nil
    return l
  end)

  local first = text:next()
  local rest = text:totable()
  vim.api.nvim_buf_set_extmark(buf, ns, 0, 0, {
    id = 1,
    virt_text_pos = "overlay",
    virt_text = first,
    virt_lines = rest,
  })
  local config = vim.api.nvim_win_get_config(win)
  config.title = vim
    .iter(trail)
    :map(function(t)
      if t[1]:gsub("%s+", "") == "" then return end
      if vim.startswith(t[1], " ") then
        t[1] = " "
        return t
      end
      t[1] = t[1]:gsub("^+", "")
      return t
    end)
    :totable()
  if #config.title == 0 then config.title[1] = { "" } end
  vim.api.nvim_win_set_config(win, config)
end

function M.show_cursor() end

function M.hide_cursor() end

return M
