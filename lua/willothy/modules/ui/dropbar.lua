local dropbar_symbol_t
local dropbar_menu_t
local dropbar_menu_entry_t

---@return fun(term: Terminal): dropbar_menu_entry_t
local function menu_entry_builder(sym)
  return function(term)
    return dropbar_menu_entry_t:new({
      components = {
        dropbar_symbol_t:new({
          icon = "",
          icon_hl = "Keyword",
          name = " " .. (term.display_name or term.name),
          name_hl = "Keyword",
          on_click = function()
            if not term.bufnr then
              term:toggle()
            else
              vim.api.nvim_win_set_buf(sym.menu.prev_win, term.bufnr)
            end
            sym.menu:close(true)
          end,
        }),
      },
    })
  end
end

---@param sym dropbar_symbol_t
---@return dropbar_menu_entry_t[]
local function get_menu_entries(sym)
  return vim
    .iter(require("toggleterm.terminal").get_all(true))
    :map(menu_entry_builder(sym))
    :totable()
end

local init = false
local function setup()
  dropbar_symbol_t = require("dropbar.bar").dropbar_symbol_t
  dropbar_menu_t = require("dropbar.menu").dropbar_menu_t
  dropbar_menu_entry_t = require("dropbar.menu").dropbar_menu_entry_t
  init = true
end

local M = {}

M.terminal = {}

function M.terminal.get_symbols()
  local toggleterm = require("toggleterm.terminal")
  local t = select(2, toggleterm.identify()) or {}
  local name = t.display_name or t.name or "Terminal"

  return {
    dropbar_symbol_t:new({
      icon = " ",
      icon_hl = "NormalNC",
      name = name,
      name_hl = "Keyword",
      on_click = function(self)
        self.menu = dropbar_menu_t:new({
          entries = get_menu_entries(self),
          prev_win = self.bar.win or vim.api.nvim_get_current_win(),
        })
        self.menu:toggle()
      end,
    }),
  }
end

return setmetatable({}, {
  __index = function(_, k)
    if not init then
      setup()
    end
    return rawget(M, k)
  end,
})
