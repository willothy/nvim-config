local function get_size()
  local round = function(n)
    if n - math.floor(n) >= 0.5 then
      return math.ceil(n)
    else
      return math.floor(n)
    end
  end
  return round(vim.o.lines / 3.5)
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
  size = { height = get_size },
  filter = function(_buf, win)
    return vim.api.nvim_win_get_config(win).zindex == nil
  end,
})

local sidebar = View.new({
  size = { width = get_size },
})

function _G.__edgy_term_title()
  local buf = vim.api.nvim_get_current_buf()
  local win = vim.api.nvim_get_current_win()
  local bar = _G.dropbar.bars[buf][win]
  bar.padding.left = 3
  return _G.dropbar.get_dropbar_str():gsub(" %s+", "")
end

local terminal = bottom:extend({
  title = "%{%v:lua.__edgy_term_title()%}",
  open = function()
    willothy.term.main:open()
  end,
  wo = {
    number = false,
    relativenumber = false,
  },
  filter = function(buf, win)
    return vim.bo[buf].buftype == "terminal"
      and vim.api.nvim_win_get_config(win).zindex == nil
  end,
})

local trouble = bottom:extend({
  ft = "Trouble",
})

local neogit = View.new({
  size = {
    width = function()
      if vim.o.columns > 120 then
        return math.floor(vim.o.columns * 0.35)
      else
        return math.floor(vim.o.columns * 0.6)
      end
    end,
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
  },
  left = {
    sidebar:extend({
      ft = "OverseerList",
      title = "Overseer",
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
      size = { height = get_size },
    }),
  },
  bottom = {
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
    terminal:extend({ ft = "terminal" }),
    terminal:extend({ ft = "toggleterm" }),
    terminal:extend({ ft = vim.o.shell }),
    bottom:extend({ ft = "noice" }),
    bottom:extend({ ft = "qf", title = "QuickFix" }),
    bottom:extend({ ft = "spectre_panel", title = "Spectre" }),
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
    bottom = { size = get_size },
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
---@param opts Edgy.View.Opts
---@diagnostic disable-next-line: duplicate-set-field
function V.new(opts, edgebar)
  local mt = getmetatable(opts)
  local self = mt and opts or setmetatable(opts, V)
  self.edgebar = edgebar
  self.wins = {}
  self.title = self.title or self.ft:sub(1, 1):upper() .. self.ft:sub(2)
  self.size = self.size or {}
  self.opening = false
  return self
end
require("edgy").setup(opts)
