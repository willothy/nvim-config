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

---@class Willothy.EdgyView
local View = {}
View.__index = View

---@param props table
function View.new(props)
  return setmetatable(props, View)
end

---@param props table
function View:extend(props)
  return setmetatable(vim.tbl_deep_extend("keep", props, self), View)
end

---@param ft string
function View:filetype(ft)
  return self:extend({ ft = ft })
end

---@param title string
function View:title(title)
  return self:extend({ title = title })
end

---@param open string | fun()
function View:open(open)
  return self:extend({ open = open })
end

local bottom = View.new({
  size = { height = get_size },
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

require("edgy").setup({
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
      title = "Watches",
      ft = "dapui_watches",
      wo = { winbar = " Watching" },
    },
    {
      title = "Stacks",
      ft = "dapui_stacks",
      wo = { winbar = " Stacks" },
    },
    {
      title = "Breakpoints",
      ft = "dapui_breakpoints",
      wo = { winbar = " Breakpoints" },
    },
    {
      title = "Scopes",
      ft = "dapui_scopes",
      wo = { winbar = " Scopes" },
      size = { height = get_size },
    },
  },
  bottom = {
    {
      ft = "dapui_console",
      title = "Debug Console",
      wo = { winbar = " Debug Console" },
      size = { height = get_size },
    },
    {
      ft = "dap-repl",
      title = "Debug REPL",
      wo = { winbar = false, statuscolumn = "" },
      size = { height = get_size },
    },
    terminal:filetype("terminal"),
    terminal:filetype("toggleterm"),
    -- {
    --   ft = "terminal",
    --   title = "%{%v:lua.dropbar.get_dropbar_str()%}",
    --   open = function()
    --     willothy.term.main:open()
    --   end,
    --   wo = {
    --     winbar = true,
    --     number = false,
    --     relativenumber = false,
    --   },
    --   filter = function(buf, win)
    --     return vim.bo[buf].buftype == "terminal"
    --       and vim.api.nvim_win_get_config(win).zindex == nil
    --   end,
    --   size = { height = get_size },
    -- },
    {
      ft = "Trouble",
      title = "Diagnostics",
      open = function()
        require("trouble").open()
      end,
      size = { height = get_size },
    },
    {
      ft = "noice",
      filter = function(_buf, win)
        return not vim.api.nvim_win_get_config(win).zindex
      end,
      size = { height = get_size },
    },
    {
      ft = "qf",
      title = "QuickFix",
      size = { height = get_size },
    },
    {
      ft = "spectre_panel",
      title = "Spectre",
      wo = {
        number = false,
        relativenumber = false,
        signcolumn = "no",
      },
      filter = function(_, win)
        if vim.api.nvim_win_get_config(win).zindex == nil then
          vim.api.nvim_win_set_cursor(win, { 1, 0 })
          return true
        end
      end,
      size = { height = get_size },
    },
  },

  options = {
    -- left = { size = 0.25 },
    bottom = { size = get_size },
  },

  exit_when_last = true,
  close_when_all_hidden = true,

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
})
