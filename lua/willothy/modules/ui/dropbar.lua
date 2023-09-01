local M = {}

local bar = require("dropbar.bar")
local menu = require("dropbar.menu")

local source = {
  get_symbols = function(_, _, _)
    return {
      bar.dropbar_symbol_t:new({
        icon = " ",
        icon_hl = "NormalNC",
        name = "Terminal",
        name_hl = "Keyword",
        on_click = function(self)
          local terms = require("toggleterm.terminal").get_all(true)

          self.menu = menu.dropbar_menu_t:new({
            entries = vim
              .iter(terms)
              :map(function(term)
                return menu.dropbar_menu_entry_t:new({
                  components = {
                    bar.dropbar_symbol_t:new({
                      icon = "",
                      icon_hl = "NormalNC",
                      name = " " .. term.name,
                      name_hl = "Keyword",
                      on_click = function()
                        if not term.bufnr then
                          term:toggle()
                        else
                          vim.api.nvim_win_set_buf(
                            self.menu.prev_win,
                            term.bufnr
                          )
                        end
                        self.menu:close(true)
                      end,
                    }),
                  },
                })
              end)
              :fold({}, function(t, v)
                table.insert(t, v)
                return t
              end),
          })
          self.menu:toggle({ prev_win = vim.api.nvim_get_current_win() })
        end,
      }),
    }
  end,
}

M.terminal = source

return M
