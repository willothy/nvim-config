local icons = willothy.ui.icons
local dropbar = require("dropbar")

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
    ["oil"] = true,
    ["trouble"] = true,
    ["qf"] = true,
    ["noice"] = true,
    ["dapui_scopes"] = true,
    ["dapui_breakpoints"] = true,
    ["dapui_stacks"] = true,
    ["dapui_watches"] = true,
    ["dapui_console"] = true,
    ["dap-repl"] = true,
    ["neocomposer-menu"] = true,
  }
  if disabled[filetype] then
    return false
  end
  if vim.api.nvim_win_get_config(win).zindex ~= nil then
    return vim.bo[buf].buftype == "terminal"
      and vim.bo[buf].filetype == "terminal"
  end
  return vim.bo[buf].buflisted == true
    and vim.bo[buf].buftype == ""
    and vim.api.nvim_buf_get_name(buf) ~= ""
end

local close = function()
  local menu = require("dropbar.utils").menu.get_current()
  if not menu then
    return
  end
  menu:close()
end

dropbar.setup({
  sources = {
    terminal = {
      name = function(buf)
        local term = require("toggleterm.terminal").find(function(term)
          return term.bufnr == buf
        end)
        local name
        if term then
          name = term.display_name or term.cmd or term.name
        else
          name = vim.api.nvim_buf_get_name(buf)
        end
        return " " .. name
      end,
      name_hl = "Normal",
    },
    lsp = {
      valid_symbols = {
        "Class",
        "Method",
        "Function",
      },
    },
    path = {
      preview = "previous",
      max_depth = 1,
    },
  },
  icons = {
    kinds = {
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
    general = {
      enable = enable,
      attach_events = {
        -- "OptionSet",
        "BufWinEnter",
        "BufWritePost",
        "FileType",
        "BufEnter",
        -- "TermEnter",
      },
    },
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
    scrollbar = {
      background = false,
    },
  },
  fzf = {
    prompt = "%#GitSignsAdd# ",
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

vim.ui.select = require("dropbar.utils.menu").select
