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

local opts = {
  right = {
    {
      ft = "NeogitStatus",
      title = "Neogit",
      size = { width = 0.3 },
      open = "Neogit",
    },
    {
      ft = "NeogitPopup",
      title = "Neogit",
      size = { width = 0.3 },
    },
    {
      ft = "NeogitCommitMessage",
      title = "Commit message",
      size = { width = 0.3 },
    },
    {
      ft = "NeogitLogView",
      title = "Neogit log",
      size = { width = 0.3 },
    },
    {
      ft = "NeogitReflogView",
      title = "Neogit log",
      size = { width = 0.3 },
    },
    {
      ft = "help",
      filter = function(buf, win)
        return vim.bo[buf].buftype == "help"
          and vim.api.nvim_win_get_config(win).zindex == nil
      end,
      size = { width = 0.3 },
    },
  },
  left = {
    {
      ft = "OverseerList",
      title = "Overseer",
      size = { width = get_size },
    },
    {
      ft = "SidebarNvim",
      title = "Sidebar",
    },
    {
      ft = "gh",
      title = "Gists",
    },
    {
      ft = "aerial",
      title = "Document Symbols",
      open = function()
        require("aerial").open()
      end,
    },
    { title = "Neotest Summary", ft = "neotest-summary" },
    {
      title = "Files",
      ft = "neo-tree",
      filter = function(buf)
        return vim.b[buf].neo_tree_source == "filesystem"
      end,
      open = "Neotree",
      size = { height = 0.5 },
    },
    {
      title = "Diagnostics",
      ft = "neo-tree",
      filter = function(buf)
        return vim.b[buf].neo_tree_source == "diagnostics"
      end,
    },
    {
      title = "Git",
      ft = "neo-tree",
      filter = function(buf)
        return vim.b[buf].neo_tree_source == "git_status"
      end,
      open = "Neotree git_status",
    },
    {
      title = "Buffers",
      ft = "neo-tree",
      filter = function(buf)
        return vim.b[buf].neo_tree_source == "buffers"
      end,
      open = "Neotree buffers",
    },
    {
      ft = "dapui_watches",
      wo = { winbar = " Watches" },
    },
    {
      ft = "dapui_stacks",
      wo = { winbar = " Stacks" },
    },
    {
      ft = "dapui_breakpoints",
      wo = { winbar = " Breakpoints" },
    },
    {
      ft = "dapui_scopes",
      wo = { winbar = " Scopes" },
      size = { height = get_size },
    },
  },
  bottom = {
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
    bottom:extend({ ft = "spectre_pabel", title = "Spectre" }),
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
