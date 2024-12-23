local function get_height()
  return math.floor((vim.o.lines / 3.5) + 0.5)
end

---@type table
local View = {}
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

function _G._edgywb()
  if not package.loaded.dropbar then
    return ""
  end
  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_get_current_buf()
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
  -- _G.edgy_winbar() ..
  return _G.dropbar():gsub(" %s+", "")
end

local function is_float(win)
  return vim.api.nvim_win_get_config(win).zindex ~= nil
end

local terminal = View.new({
  ft = "terminal",
  -- title = "%{%v:lua._edgywb()%}",
  wo = {
    -- winbar = "%{%v:lua.__edgy_term_title()%}",
    number = false,
    relativenumber = false,
    winhighlight = "Normal:Normal",
  },
  filter = function(buf, win)
    return vim.bo[buf].buftype == "terminal" and not is_float(win)
  end,
})

local trouble = bottom:extend({
  ft = "trouble",
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
  -- right = {
  --   neogit:extend({
  --     ft = "NeogitStatus",
  --     title = "Neogit",
  --     open = function()
  --       require("neogit").open()
  --     end,
  --   }),
  --   neogit:extend({
  --     ft = "NeogitPopup",
  --     title = "Neogit",
  --     open = function()
  --       require("neogit").open()
  --     end,
  --   }),
  --   neogit:extend({
  --     ft = "NeogitCommitMessage",
  --     title = "Commit message",
  --   }),
  --   neogit:extend({
  --     ft = "NeogitLogView",
  --     title = "Neogit log",
  --     open = function()
  --       require("neogit").open({ "log" })
  --     end,
  --   }),
  --   neogit:extend({
  --     ft = "NeogitReflogView",
  --     title = "Neogit log",
  --     open = function()
  --       require("neogit").open({ "log" })
  --     end,
  --   }),
  --   terminal:extend({
  --     open = function()
  --       willothy.terminal.vertical:open()
  --     end,
  --     filter = function(buf, win)
  --       if not terminal.filter(buf, win) then
  --         return false
  --       end
  --       local term = require("toggleterm.terminal").find(function(term)
  --         return term.bufnr == buf
  --       end)
  --       return (vim.bo[buf].buftype == "terminal" and term == nil)
  --         or (term ~= nil and term.direction == "vertical")
  --     end,
  --     size = {
  --       width = get_rhs_width,
  --     },
  --   }),
  --   -- sidebar:extend({
  --   --   ft = "markdown.cody_history",
  --   --   filter = function(buf, win)
  --   --     return vim.api.nvim_win_get_config(win).zindex == nil
  --   --   end,
  --   --   size = {
  --   --     height = 0.8,
  --   --   },
  --   -- }),
  --   -- sidebar:extend({
  --   --   ft = "markdown.cody_prompt",
  --   --   filter = function(buf, win)
  --   --     return vim.api.nvim_win_get_config(win).zindex == nil
  --   --   end,
  --   --   size = {
  --   --     height = 0.2,
  --   --   },
  --   -- }),
  -- },
  -- left = {
  --   sidebar:extend({
  --     ft = "OverseerList",
  --     title = "Overseer",
  --     filter = function(_buf, win)
  --       return vim.api.nvim_win_get_config(win).zindex == nil
  --     end,
  --     wo = {
  --       winhighlight = "WinBar:WinBar",
  --     },
  --     open = function()
  --       require("overseer").open()
  --     end,
  --   }),
  --   -- sidebar:extend({
  --   --   ft = "oil",
  --   --   -- open = function()
  --   --   --   require("oil").open()
  --   --   -- end,
  --   --   wo = {
  --   --     winbar = "%{%v:lua.require('oil').winbar()%}",
  --   --   },
  --   --   size = {
  --   --     width = function()
  --   --       if vim.o.columns > 140 then
  --   --         return 35
  --   --       else
  --   --         return math.floor(vim.o.columns * 0.25)
  --   --       end
  --   --     end,
  --   --   },
  --   -- }),
  --   sidebar:extend({
  --     ft = "SidebarNvim",
  --     title = "Sidebar",
  --     open = function()
  --       require("sidebar-nvim").open()
  --     end,
  --   }),
  --   sidebar:extend({
  --     ft = "aerial",
  --     title = "Document Symbols",
  --     open = function()
  --       require("aerial").open()
  --     end,
  --   }),
  --   sidebar:extend({
  --     title = "Neotest Summary",
  --     ft = "neotest-summary",
  --     open = function()
  --       require("neotest").summary.open()
  --     end,
  --   }),
  --   sidebar:extend({
  --     title = "Files",
  --     ft = "neo-tree",
  --     filter = function(buf, win)
  --       return vim.b[buf].neo_tree_source == "filesystem" and not is_float(win)
  --     end,
  --     open = function()
  --       vim.cmd.Neotree("filesystem")
  --     end,
  --   }),
  --   sidebar:extend({
  --     title = "Diagnostics",
  --     ft = "neo-tree",
  --     filter = function(buf, win)
  --       return vim.b[buf].neo_tree_source == "diagnostics"
  --         and not is_float(win)
  --     end,
  --     open = function()
  --       vim.cmd.Neotree("diagnostics")
  --     end,
  --   }),
  --   sidebar:extend({
  --     title = "Git",
  --     ft = "neo-tree",
  --     filter = function(buf, win)
  --       return vim.b[buf].neo_tree_source == "git_status" and not is_float(win)
  --     end,
  --     open = function()
  --       vim.cmd.Neotree("git_status")
  --     end,
  --   }),
  --   sidebar:extend({
  --     title = "Buffers",
  --     ft = "neo-tree",
  --     filter = function(buf, win)
  --       return vim.b[buf].neo_tree_source == "buffers" and not is_float(win)
  --     end,
  --     open = function()
  --       vim.cmd.Neotree("buffers")
  --     end,
  --   }),
  --   sidebar:extend({
  --     ft = "dapui_watches",
  --     wo = { winbar = " Watches" },
  --     open = function()
  --       require("dapui").open()
  --     end,
  --   }),
  --   sidebar:extend({
  --     ft = "dapui_stacks",
  --     wo = { winbar = " Stacks" },
  --     open = function()
  --       require("dapui").open()
  --     end,
  --   }),
  --   sidebar:extend({
  --     ft = "dapui_breakpoints",
  --     wo = { winbar = " Breakpoints" },
  --     open = function()
  --       require("dapui").open()
  --     end,
  --   }),
  --   sidebar:extend({
  --     ft = "dapui_scopes",
  --     wo = { winbar = " Scopes" },
  --     size = { height = get_height },
  --     open = function()
  --       require("dapui").open()
  --     end,
  --   }),
  -- },
  bottom = {
    {
      ft = "terminal",
      title = "%{%v:lua._edgywb()%}",
      wo = {
        number = false,
        relativenumber = false,
        cursorline = false,
        winhighlight = "Normal:Normal",
      },
      open = function()
        willothy.terminal.main:open()
      end,
      filter = function(buf, win)
        if vim.bo[buf].buftype ~= "terminal" or is_float(win) then
          return false
        end
        local term = require("toggleterm.terminal").find(function(term)
          return term.bufnr == buf
        end)
        return (vim.bo[buf].buftype == "terminal" and term == nil)
          or (term ~= nil and term.direction == "horizontal")
      end,
      size = { height = get_height },
    },
    -- bottom:extend({
    --   ft = "norg",
    --   size = {
    --     height = 14,
    --     width = 1.0,
    --   },
    --   wo = {
    --     winbar = false,
    --     statuscolumn = "",
    --     foldcolumn = "0",
    --   },
    --   filter = function(buf)
    --     return vim.bo[buf].buftype == "nofile"
    --   end,
    -- }),
    -- bottom:extend({
    --   ft = "dapui_console",
    --   title = "Debug Console",
    --   wo = { winbar = " Debug Console" },
    --   open = function()
    --     require("dapui").open()
    --   end,
    -- }),
    -- bottom:extend({
    --   ft = "dap-repl",
    --   title = "Debug REPL",
    --   wo = { winbar = false, statuscolumn = "" },
    --   open = function()
    --     require("dapui").open()
    --   end,
    -- }),
    -- bottom:extend({
    --   ft = "neotest-output-panel",
    --   title = "Neotest output",
    --   open = function()
    --     require("neotest").output_panel.open()
    --   end,
    -- }),
    -- bottom:extend({
    --   ft = "noice",
    --   open = function()
    --     vim.cmd.Noice()
    --   end,
    -- }),
    -- bottom:extend({
    --   ft = "qf",
    --   title = "QuickFix",
    --   wo = {
    --     winhighlight = "Normal:Normal",
    --   },
    --   open = function()
    --     vim.cmd.copen()
    --   end,
    -- }),
    -- bottom:extend({
    --   ft = "spectre_panel",
    --   title = "Spectre",
    --   wo = {
    --     number = false,
    --     relativenumber = false,
    --   },
    --   open = function()
    --     require("spectre").open()
    --   end,
    -- }),
    trouble,
  },

  options = {
    -- left = { size = 0.25 },
    bottom = { size = get_height },
  },

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
  },
}

-- local A = require("edgy.animate")
--
-- local timer
-- ---@diagnostic disable-next-line: duplicate-set-field
-- A.schedule = function()
--   if not (timer and timer:is_active()) then
--     timer = vim.defer_fn(function()
--       if A.animate() then
--         -- require("focus").focus_disable()
--         vim.g.minianimate_disable = true
--         A.schedule()
--       else
--         vim.g.minianimate_disable = false
--         -- require("focus").focus_enable()
--       end
--     end, 1000 / opts.animate.fps)
--   end
-- end
--
-- local V = require("edgy.view")
-- ---@param view Edgy.View.Opts
-- ---@diagnostic disable: duplicate-set-field
-- ---@diagnostic disable: inject-field
-- function V.new(view, edgebar)
--   local mt = getmetatable(view)
--   local self = mt and view or setmetatable(view, V)
--   self.edgebar = edgebar
--   self.wins = {}
--   self.title = self.title or self.ft:sub(1, 1):upper() .. self.ft:sub(2)
--   self.size = self.size or {}
--   self.opening = false
--   return self
-- end

require("edgy").setup(opts)
