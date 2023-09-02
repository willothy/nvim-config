local icons = willothy.icons
local dropbar = require("dropbar")

local enable = function(buf, win)
  if
    require("cokeline.sidebar").get_win("left") == win
    or require("cokeline.sidebar").get_win("right") == win
  then
    return false
  end
  if vim.wo[win].diff then
    return false
  end
  local filetype = vim.bo[buf].filetype
  local disabled = {
    "Trouble",
    -- "terminal",
    "qf",
    "noice",
    "dapui_scopes",
    "dapui_breakpoints",
    "dapui_stacks",
    "dapui_watches",
    "dapui_console",
    "dap-repl",
  }
  return (vim.bo[buf].buflisted == true or vim.bo[buf].buftype == "terminal")
    and (vim.bo[buf].buftype == "" or vim.bo[buf].buftype == "terminal")
    and vim.api.nvim_buf_get_name(buf) ~= ""
    and not disabled[filetype]
end

local sources = function(buf, _)
  local builtin = require("dropbar.sources")
  local utils = require("dropbar.utils")
  if vim.bo[buf].ft == "markdown" then
    return {
      builtin.path,
      utils.source.fallback({
        builtin.treesitter,
        builtin.markdown,
        builtin.lsp,
      }),
    }
  end
  if vim.bo[buf].ft == "terminal" then
    return {
      setmetatable({}, {
        __index = function(_, k)
          return require("willothy.modules.ui.dropbar").terminal[k]
        end,
      }),
    }
  end
  return {
    builtin.path,
    utils.source.fallback({
      builtin.lsp,
      builtin.treesitter,
    }),
  }
end

local fuzzy_find = function()
  local api = require("dropbar.api")
  local m = api.get_current_dropbar_menu()
  if m then
    m:fuzzy_find_open({
      win_configs = {
        border = "none",
      },
      prompt = "%#GitSignsAdd#   ",
    })
  end
end

local close = function()
  local api = require("dropbar.api")
  local m = api.get_current_dropbar_menu()
  if not m then
    return
  end
  m:close()
end

dropbar.setup({
  general = {
    enable = enable,
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
    sources = sources,
  },
  menu = {
    keymaps = {
      f = fuzzy_find,
      i = fuzzy_find,
      q = close,
      ["<Esc>"] = close,
    },
  },
})

local function attach(win)
  local buf = vim.api.nvim_win_get_buf(win)
  if require("dropbar.configs").eval(enable, buf, win) then
    vim.wo[win].winbar = "%{%v:lua.dropbar.get_dropbar_str()%}"
  end
end

vim.iter(vim.api.nvim_list_wins()):each(attach)
