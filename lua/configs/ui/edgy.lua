local function get_height()
  return math.floor((vim.o.lines / 3.5) + 0.5)
end

---@type table
local View = setmetatable({}, { __index = require("edgy.view") })
View.__index = View

---@param props table
function View.new(props)
  return setmetatable(props, View)
end

---@param props table
function View:extend(props)
  return setmetatable(props, { __index = self })
end

local bottom = View.new({
  size = { height = get_height },
  filter = function(_buf, win)
    return vim.api.nvim_win_get_config(win).zindex == nil
  end,
})

local sidebar = View.new({
  size = {
    width = function()
      if vim.o.columns > 120 then
        return math.floor((vim.o.columns * 0.1) + 0.5)
      else
        return math.floor((vim.o.columns * 0.25) + 0.5)
      end
    end,
  },
})

function _G.__edgy_term_title()
  local buf = vim.api.nvim_get_current_buf()
  local win = vim.api.nvim_get_current_win()
  local bar = _G.dropbar.bars[buf][win]
  bar.padding.left = 3
  return _G.dropbar.get_dropbar_str():gsub(" %s+", "")
end

local terminal = View.new({
  ft = "terminal",
  title = "%{%v:lua.__edgy_term_title()%}",
  wo = {
    number = false,
    relativenumber = false,
    winhighlight = "Normal:Normal",
  },
  filter = function(buf, win)
    return vim.bo[buf].buftype == "terminal"
  end,
})

local trouble = bottom:extend({
  ft = "Trouble",
})

local function get_rhs_width()
  if vim.o.columns > 120 then
    return math.floor(vim.o.columns * 0.35)
  else
    return math.floor(vim.o.columns * 0.6)
  end
end

local neogit = View.new({
  size = {
    width = get_rhs_width,
  },
})

local opts = {
  right = {
    neogit:extend({
      ft = "NeogitStatus",
      title = "Neogit",
      open = "Neogit",
    }),
    neogit:extend({
      ft = "NeogitPopup",
      title = "Neogit",
    }),
    neogit:extend({
      ft = "NeogitCommitMessage",
      title = "Commit message",
    }),
    neogit:extend({
      ft = "NeogitLogView",
      title = "Neogit log",
    }),
    neogit:extend({
      ft = "NeogitReflogView",
      title = "Neogit log",
    }),
    terminal:extend({
      open = function()
        willothy.term.vertical:open()
      end,
      filter = function(buf, win)
        return vim.bo[buf].buftype == "terminal"
          and willothy.term.get_direction(buf, win) == "vertical"
      end,
      size = {
        width = get_rhs_width,
      },
    }),
  },
  left = {
    sidebar:extend({
      ft = "OverseerList",
      title = "Overseer",
      filter = function(_buf, win)
        return vim.api.nvim_win_get_config(win).zindex == nil
      end,
    }),
    sidebar:extend({
      ft = "SidebarNvim",
      title = "Sidebar",
    }),
    sidebar:extend({
      ft = "gh",
      title = "Gists",
    }),
    sidebar:extend({
      ft = "aerial",
      title = "Document Symbols",
      open = function()
        require("aerial").open()
      end,
    }),
    sidebar:extend({
      title = "Neotest Summary",
      ft = "neotest-summary",
    }),
    sidebar:extend({
      title = "Files",
      ft = "neo-tree",
      filter = function(buf)
        return vim.b[buf].neo_tree_source == "filesystem"
      end,
      open = "Neotree",
    }),
    sidebar:extend({
      title = "Diagnostics",
      ft = "neo-tree",
      filter = function(buf)
        return vim.b[buf].neo_tree_source == "diagnostics"
      end,
    }),
    sidebar:extend({
      title = "Git",
      ft = "neo-tree",
      filter = function(buf)
        return vim.b[buf].neo_tree_source == "git_status"
      end,
      open = "Neotree git_status",
    }),
    sidebar:extend({
      title = "Buffers",
      ft = "neo-tree",
      filter = function(buf)
        return vim.b[buf].neo_tree_source == "buffers"
      end,
      open = "Neotree buffers",
    }),
    sidebar:extend({
      ft = "dapui_watches",
      wo = { winbar = " Watches" },
    }),
    sidebar:extend({
      ft = "dapui_stacks",
      wo = { winbar = " Stacks" },
    }),
    sidebar:extend({
      ft = "dapui_breakpoints",
      wo = { winbar = " Breakpoints" },
    }),
    sidebar:extend({
      ft = "dapui_scopes",
      wo = { winbar = " Scopes" },
      size = { height = get_height },
    }),
  },
  bottom = {
    terminal:extend({
      open = function()
        willothy.term.main:open()
      end,
      filter = function(buf, win)
        return vim.bo[buf].buftype == "terminal"
          and willothy.term.get_direction(buf, win) == "horizontal"
      end,
      size = { height = get_height },
    }),
    {
      ft = "help",
      filter = function(buf, win)
        return vim.bo[buf].buftype == "help"
          and vim.api.nvim_win_get_config(win).zindex == nil
      end,
      size = { height = 0.4 },
    },
    bottom:extend({
      ft = "dapui_console",
      title = "Debug Console",
      wo = { winbar = " Debug Console" },
    }),
    bottom:extend({
      ft = "dap-repl",
      title = "Debug REPL",
      wo = { winbar = false, statuscolumn = "" },
    }),
    bottom:extend({
      ft = "noice",
    }),
    bottom:extend({
      ft = "qf",
      title = "QuickFix",
      wo = {
        winhighlight = "Normal:Normal",
      },
    }),
    bottom:extend({
      ft = "spectre_panel",
      title = "Spectre",
      wo = {
        number = false,
        relativenumber = false,
      },
    }),
    trouble:extend({
      title = "Diagnostics",
      filter = function(buf)
        return vim.b[buf].trouble_mode == "document_diagnostics"
          or vim.b[buf].trouble_mode == "workspace_diagnostics"
      end,
    }),
    trouble:extend({
      title = "References",
      filter = function(buf)
        return vim.b[buf].trouble_mode == "lsp_references"
      end,
    }),
    trouble:extend({
      title = "Definitions",
      filter = function(buf)
        return vim.b[buf].trouble_mode == "lsp_definitions"
      end,
    }),
    trouble:extend({
      title = "Type Definitions",
      filter = function(buf)
        return vim.b[buf].trouble_mode == "lsp_type_definitions"
      end,
    }),
    trouble:extend({
      title = "QuickFix",
      filter = function(buf)
        return vim.b[buf].trouble_mode == "quickfix"
      end,
    }),
    trouble:extend({
      title = "LocList",
      filter = function(buf)
        return vim.b[buf].trouble_mode == "loclist"
      end,
    }),
  },

  options = {
    -- left = { size = 0.25 },
    bottom = { size = get_height },
  },

  exit_when_last = true,
  close_when_all_hidden = true,
  restore_terminals = true,

  wo = {
    winhighlight = "",
  },

  keys = {
    -- ["q"] = false,
    ["Q"] = false,
  },

  animate = {
    enabled = true,
    fps = 60,
    cps = 180,
    on_begin = function()
      vim.g.minianimate_disable = true
    end,
    on_end = function()
      vim.g.minianimate_disable = false
    end,
  },
}

local V = require("edgy.view")
---@param view Edgy.View.Opts
---@diagnostic disable-next-line: duplicate-set-field
function V.new(view, edgebar)
  local mt = getmetatable(view)
  local self = mt and view or setmetatable(view, V)
  self.edgebar = edgebar
  self.wins = {}
  self.title = self.title or self.ft:sub(1, 1):upper() .. self.ft:sub(2)
  self.size = self.size or {}
  self.opening = false
  return self
end
require("edgy").setup(opts)
