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
  return _G.dropbar():gsub(" %s+$", "")
end

local function is_float(win)
  return vim.api.nvim_win_get_config(win).zindex ~= nil
end

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
  -- },
  -- left = {
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
        require("willothy.terminal").main:open()
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
    -- bottom:extend({
    --   ft = "noice",
    --   open = function()
    --     vim.cmd.Noice()
    --   end,
    -- }),
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

for _, pos in ipairs({ "top", "bottom", "left", "right" }) do
  opts[pos] = opts[pos] or {}
  table.insert(opts[pos] --[[@as table]], {
    ft = "snacks_terminal",
    size = { height = get_height },
    -- title = "%{b:snacks_terminal.id}: %{b:term_title}",
    title = "%{%v:lua.dropbar()%}: %{b:term_title}",

    -- title = "%{%v:lua._edgywb()%}",
    wo = {
      number = false,
      relativenumber = false,
      cursorline = false,
      winhighlight = "Normal:Normal",
    },
    filter = function(_buf, win)
      return vim.w[win].snacks_win
        and vim.w[win].snacks_win.position == pos
        and vim.w[win].snacks_win.relative == "editor"
        and not vim.w[win].trouble_preview
    end,
  })
end

require("edgy").setup(opts)
