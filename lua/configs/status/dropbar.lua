local icons = willothy.icons
local dropbar = require("dropbar")

local opts = {
  general = {
    -- enable = function(buf, win)
    --   if vim.api.nvim_win_get_config(win).relative ~= "" then
    --     return false
    --   end
    --   if
    --     require("cokeline.sidebar").get_win("left") == win
    --     or require("cokeline.sidebar").get_win("right") == win
    --   then
    --     return false
    --   end
    --   if vim.wo[win].diff then
    --     return false
    --   end
    --   local filetype = vim.bo[buf].filetype
    --   local disabled = {
    --     "Trouble",
    --     "terminal",
    --     "qf",
    --     "noice",
    --     "dapui_scopes",
    --     "dapui_breakpoints",
    --     "dapui_stacks",
    --     "dapui_watches",
    --     "dapui_console",
    --     "dap-repl",
    --   }
    --   return vim.bo[buf].buflisted
    --     and vim.bo[buf].buftype == ""
    --     and vim.api.nvim_buf_get_name(buf) ~= ""
    --     and not disabled[filetype]
    -- end,
  },
  icons = {
    kinds = {
      use_devicons = true,
      symbols = icons.kinds,
    },
    ui = {
      bar = {
        separator = string.format(" %s ", icons.separators.angle_quote.right),
        extends = icons.misc.ellipse,
      },
    },
  },
  bar = {
    padding = {
      left = 0,
      right = 1,
    },
  },
  menu = {
    keymaps = {
      q = function()
        local api = require("dropbar.api")
        local m = api.get_current_dropbar_menu()
        if not m then
          return
        end
        m:close()
      end,
      ["<Esc>"] = function()
        local api = require("dropbar.api")
        local m = api.get_current_dropbar_menu()
        if not m then
          return
        end
        m:close()
      end,
    },
  },
}

dropbar.setup(opts)
local winbar = vim.wo.winbar
vim
  .iter(vim.api.nvim_list_wins())
  :filter(function(win)
    return vim.api.nvim_win_get_config(win).relative == ""
  end)
  :each(function(win)
    vim.wo[win].winbar = winbar
  end)
