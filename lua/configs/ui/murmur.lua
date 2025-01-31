local M = {}

local au = vim.api.nvim_create_augroup("murmur_au", { clear = true })
local enabled = true
local active_win

vim.api.nvim_set_hl(0, "Cursorword", {})

require("murmur").setup({
  exclude_filetypes = {
    "neo-tree",
    "noice",
    "SidebarNvim",
    "terminal",
    "trouble",
  },
  cursor_rgb = "Cursorword",
  cursor_rgb_current = "Cursorword",
  cursor_rgb_always_use_config = true,
  callbacks = {
    function()
      if active_win and vim.api.nvim_win_is_valid(active_win) then
        vim.api.nvim_win_close(active_win, true)
      end
      active_win = nil
    end,
  },
})

-- TODO: this functionality should not be
-- in the plugin config.
function M.enable()
  enabled = true
end

function M.disable()
  enabled = false
  M.hide()
end

function M.toggle()
  enabled = not enabled
  if not enabled then
    M.hide()
  end
end

function M.hide()
  if active_win and vim.api.nvim_win_is_valid(active_win) then
    vim.api.nvim_win_close(active_win, true)
  end
  active_win = nil
end

function M.show()
  if
    (active_win and vim.api.nvim_win_is_valid(active_win))
    or (vim.w.cursor_word == "" or vim.w.cursor_word == nil)
    or (require("noice.lsp.docs").get("hover"):win() ~= nil)
    or not enabled
  then
    return
  end

  local buf, win = vim.diagnostic.open_float({
    scope = "cursor",
    close_events = {
      "InsertEnter",
      "TextChanged",
      "BufLeave",
    },
  })
  if not buf or not win then
    return
  end
  active_win = win
  vim.api.nvim_create_autocmd("WinClosed", {
    group = au,
    buffer = buf,
    once = true,
    callback = function()
      active_win = nil
    end,
  })
end

local docs = require("noice.lsp.docs")
local get = docs.get
---@diagnostic disable-next-line: duplicate-set-field
docs.get = function(name)
  if name == "hover" then
    M.hide()
  end
  return get(name)
end

require("snacks").toggle
  .new({
    name = "Diagnostic float",
    get = function()
      return enabled
    end,
    set = function(value)
      enabled = value
      if enabled then
        M.show()
      else
        M.hide()
      end
    end,
  })
  :map("<leader>uF")

-- To create IDE-like no blinking diagnostic message with `cursor` scope. (should be paired with the callback above)
vim.api.nvim_create_autocmd("CursorHold", {
  group = au,
  pattern = "*",
  callback = M.show,
})
