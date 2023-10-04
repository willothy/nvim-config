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
  if vim.bo[buf].bt == "terminal" and not vim.b[buf].__dropbar_ready then
    local old = bar.update_hover_hl
    ---@diagnostic disable-next-line: duplicate-set-field
    bar.update_hover_hl = function(self, col)
      if col ~= nil then
        col = col - 3
      end
      return old(self, col)
    end
    vim.b[buf].__dropbar_ready = true
  end
  return _G.dropbar.get_dropbar_str():gsub(" %s+", "")
end

local function is_float(win)
  return vim.api.nvim_win_get_config(win).zindex ~= nil
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
    return vim.bo[buf].buftype == "terminal" and not is_float(win)
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
      open = function()
        require("neogit").open()
      end,
    }),
    neogit:extend({
      ft = "NeogitPopup",
      title = "Neogit",
      open = function()
        require("neogit").open()
      end,
    }),
    neogit:extend({
      ft = "NeogitCommitMessage",
      title = "Commit message",
    }),
    neogit:extend({
      ft = "NeogitLogView",
      title = "Neogit log",
      open = function()
        require("neogit").open({ "log" })
      end,
    }),
    neogit:extend({
      ft = "NeogitReflogView",
      title = "Neogit log",
      open = function()
        require("neogit").open({ "log" })
      end,
    }),
    terminal:extend({
      open = function()
        willothy.term.vertical:open()
      end,
      filter = function(buf)
        local term = require("toggleterm.terminal").find(function(term)
          return term.bufnr == buf
        end)
        return (vim.bo[buf].buftype == "terminal" and term == nil)
          or (term ~= nil and term.direction == "vertical")
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
      open = function()
        require("overseer").open()
      end,
    }),
    sidebar:extend({
      ft = "SidebarNvim",
      title = "Sidebar",
      open = "SidebarNvimOpen",
    }),
    sidebar:extend({
      ft = "gh",
      title = "Gists",
      open = "GistsList",
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
      open = function()
        require("neotest").summary.open()
      end,
    }),
    sidebar:extend({
      title = "Files",
      ft = "neo-tree",
      filter = function(buf, win)
        return vim.b[buf].neo_tree_source == "filesystem" and not is_float(win)
      end,
      open = function()
        vim.cmd.Neotree("filesystem")
      end,
    }),
    sidebar:extend({
      title = "Diagnostics",
      ft = "neo-tree",
      filter = function(buf, win)
        return vim.b[buf].neo_tree_source == "diagnostics"
          and not is_float(win)
      end,
      open = function()
        vim.cmd.Neotree("diagnostics")
      end,
    }),
    sidebar:extend({
      title = "Git",
      ft = "neo-tree",
      filter = function(buf, win)
        return vim.b[buf].neo_tree_source == "git_status" and not is_float(win)
      end,
      open = function()
        vim.cmd.Neotree("git_status")
      end,
    }),
    sidebar:extend({
      title = "Buffers",
      ft = "neo-tree",
      filter = function(buf, win)
        return vim.b[buf].neo_tree_source == "buffers" and not is_float(win)
      end,
      open = function()
        vim.cmd.Neotree("buffers")
      end,
    }),
    sidebar:extend({
      ft = "dapui_watches",
      wo = { winbar = " Watches" },
      open = function()
        require("dapui").open()
      end,
    }),
    sidebar:extend({
      ft = "dapui_stacks",
      wo = { winbar = " Stacks" },
      open = function()
        require("dapui").open()
      end,
    }),
    sidebar:extend({
      ft = "dapui_breakpoints",
      wo = { winbar = " Breakpoints" },
      open = function()
        require("dapui").open()
      end,
    }),
    sidebar:extend({
      ft = "dapui_scopes",
      wo = { winbar = " Scopes" },
      size = { height = get_height },
      open = function()
        require("dapui").open()
      end,
    }),
  },
  bottom = {
    terminal:extend({
      open = function()
        willothy.term.main:open()
      end,
      filter = function(buf)
        local term = require("toggleterm.terminal").find(function(term)
          return term.bufnr == buf
        end)
        return (vim.bo[buf].buftype == "terminal" and term == nil)
          or (term ~= nil and term.direction == "horizontal")
      end,
      size = { height = get_height },
    }),
    {
      ft = "help",
      filter = function(buf, win)
        return vim.bo[buf].buftype == "help"
          and vim.api.nvim_win_get_config(win).zindex == nil
      end,
      open = function()
        vim.cmd.help()
      end,
      size = { height = 0.4 },
    },
    bottom:extend({
      ft = "dapui_console",
      title = "Debug Console",
      wo = { winbar = " Debug Console" },
      open = function()
        require("dapui").open()
      end,
    }),
    bottom:extend({
      ft = "dap-repl",
      title = "Debug REPL",
      wo = { winbar = false, statuscolumn = "" },
      open = function()
        require("dapui").open()
      end,
    }),
    bottom:extend({
      ft = "neotest-output-panel",
      title = "Neotest output",
      open = function()
        require("neotest").output_panel.open()
      end,
    }),
    bottom:extend({
      ft = "noice",
      open = function()
        vim.cmd.Noice()
      end,
    }),
    bottom:extend({
      ft = "qf",
      title = "QuickFix",
      wo = {
        winhighlight = "Normal:Normal",
      },
      open = function()
        vim.cmd.copen()
      end,
    }),
    bottom:extend({
      ft = "spectre_panel",
      title = "Spectre",
      wo = {
        number = false,
        relativenumber = false,
      },
      open = function()
        require("spectre").open()
      end,
    }),
    trouble:extend({
      title = "Diagnostics",
      filter = function(buf, win)
        return (
          vim.b[buf].trouble_mode == "document_diagnostics"
          or vim.b[buf].trouble_mode == "workspace_diagnostics"
          or vim.b[buf].trouble_mode == nil
        ) and not is_float(win)
      end,
      open = function()
        require("trouble").open("document_diagnostics")
      end,
    }),
    trouble:extend({
      title = "References",
      filter = function(buf, win)
        return vim.b[buf].trouble_mode == "lsp_references"
          and not is_float(win)
      end,
      open = function()
        require("trouble").open("lsp_references")
      end,
    }),
    trouble:extend({
      title = "Definitions",
      filter = function(buf, win)
        return vim.b[buf].trouble_mode == "lsp_definitions"
          and not is_float(win)
      end,
      open = function()
        require("trouble").open("lsp_definitions")
      end,
    }),
    trouble:extend({
      title = "Type Definitions",
      filter = function(buf, win)
        return vim.b[buf].trouble_mode == "lsp_type_definitions"
          and not is_float(win)
      end,
      open = function()
        require("trouble").open("lsp_type_definitions")
      end,
    }),
    trouble:extend({
      title = "QuickFix",
      filter = function(buf, win)
        return vim.b[buf].trouble_mode == "quickfix" and not is_float(win)
      end,
      open = function()
        require("trouble").open("quickfix")
      end,
    }),
    trouble:extend({
      title = "LocList",
      filter = function(buf, win)
        return vim.b[buf].trouble_mode == "loclist" and not is_float(win)
      end,
      open = function()
        require("trouble").open("loclist")
      end,
    }),
  },

  options = {
    -- left = { size = 0.25 },
    bottom = { size = get_height },
  },

  -- exit_when_last = true,
  exit_when_last = false,
  close_when_all_hidden = true,

  wo = {
    winhighlight = "",
  },

  keys = {
    ["Q"] = false,
  },

  animate = {
    enabled = true,
    fps = 60,
    cps = 160,
    on_begin = function() end,
    on_end = function() end,
  },
}

local A = require("edgy.animate")

local timer
---@diagnostic disable-next-line: duplicate-set-field
A.schedule = function()
  if not (timer and timer:is_active()) then
    timer = vim.defer_fn(function()
      if A.animate() then
        require("focus").focus_disable()
        vim.g.minianimate_disable = true
        A.schedule()
      else
        vim.g.minianimate_disable = false
        require("focus").focus_enable()
      end
    end, 1000 / opts.animate.fps)
  end
end

local V = require("edgy.view")
---@param view Edgy.View.Opts
---@diagnostic disable: duplicate-set-field
---@diagnostic disable: inject-field
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
