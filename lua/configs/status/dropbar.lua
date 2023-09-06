local icons = willothy.icons
local dropbar = require("dropbar")
local utils = require("dropbar.utils")

local enable = function(buf, win)
  -- if
  --   require("cokeline.sidebar").get_win("left") == win
  --   or require("cokeline.sidebar").get_win("right") == win
  -- then
  --   return false
  -- end
  -- if vim.wo[win].diff then
  --   return false
  -- end
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
  if vim.bo[buf].buftype == "terminal" then
    return
    -- return true
  end
  return vim.bo[buf].buflisted == true
    and vim.bo[buf].buftype == ""
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
    attach_events = {
      "OptionSet",
      "BufWinEnter",
      "BufWritePost",
      -- "FileType",
      -- "BufEnter",
      -- "TermEnter",
    },
  },
  sources = {
    terminal = {
      name = function(buf)
        local name = vim.api.nvim_buf_get_name(buf)
        local term = select(2, require("toggleterm.terminal").identify(name))
        if term then
          return " "
            .. (
              term.display_name
              or term.cmd
              or term.name
              or vim.api.nvim_buf_get_name(term.bufnr)
            )
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
    quick_navigation = true,
    win_configs = {
      -- border = "single",
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

willothy.event.on("ResessionPostLoad", function()
  vim
    .iter(vim.api.nvim_list_wins())
    :map(function(win)
      return vim.api.nvim_win_get_buf(win), win
    end)
    :filter(enable)
    :each(function(_, win)
      vim.wo[win].winbar = "%{%v:lua.dropbar.get_dropbar_str()%}"
    end)
  utils.bar.exec("update", {}, {})
end)
willothy.event.emit("ResessionPostLoad")
