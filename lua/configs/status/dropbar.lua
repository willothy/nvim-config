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

local fuzzy_find = function()
  local menu = require("dropbar.utils").menu.get_current()
  if not menu then
    return
  end
  menu:fuzzy_find_open()
end

local close = function()
  local menu = require("dropbar.utils").menu.get_current()
  if not menu then
    return
  end
  menu:close()
end

dropbar.setup({
  general = {
    enable = enable,
  },
  sources = {
    terminal = {
      name = function(buf)
        local name = vim.api.nvim_buf_get_name(buf)
        local term = select(2, require("toggleterm.terminal").identify(name))
        if term then
          return " " .. (term.display_name or term.name)
        else
          return " " .. name
        end
      end,
    },
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
      q = close,
      ["<Esc>"] = close,
    },
  },
  fzf = {
    prompt = "%#GitSignsAdd#  ",
    keymaps = {
      ["<C-j>"] = function()
        require("dropbar.api").fuzzy_find_navigate("down")
      end,
      ["<C-k>"] = function()
        require("dropbar.api").fuzzy_find_navigate("up")
      end,
    },
  },
})

vim.o.winbar = "%{%v:lua.dropbar.get_dropbar_str()%}"
