local fs = require("willothy.util.fs")
local hl = require("willothy.util.hl")
local icons = require("willothy.util.icons")
local mode = require("willothy.ui.modenr")

local SEP = {}
SEP.LEFT = icons.blocks.left[4]
SEP.RIGHT = icons.blocks.right.half

local Mode = {
  {
    provider = SEP.LEFT,
    hl = function()
      return mode.get_color()
    end,
  },
  {
    provider = function()
      return mode.get_name()
    end,
  },
  {
    provider = SEP.RIGHT,
    hl = function()
      return mode.get_color()
    end,
  },
  update = {
    "ModeChanged",
  },
  lazy = false,
}

local Location = {
  {
    provider = SEP.LEFT,
    hl = function()
      return mode.get_color()
    end,
  },
  {
    provider = function()
      local line = vim.fn.line(".")
      local col = vim.fn.col(".")
      local maxline = vim.fn.line("$")
      local s = math.floor((line / maxline) * 100)
        .. "%%/"
        .. string.format("%d:%d", maxline, col)
      local width = s:len() + math.max(#tostring(col), 2)

      return "%" .. width .. "=" .. s .. "%" .. width .. ")"
    end,
  },
  {
    provider = SEP.RIGHT,
    hl = function()
      return mode.get_color()
    end,
  },
  update = {
    "BufEnter",
    "BufNew",
    "CursorMoved",
    "CursorMovedI",
    "ModeChanged",
  },
  lazy = false,
}

local Devicon = {
  fetch = function(self)
    local filename = vim.fn.expand("%")
    local extension = vim.fn.fnamemodify(filename, ":e")
    local devicons = require("nvim-web-devicons")
    self.icon, self.icon_color = devicons.get_icon_color(filename, extension)
    if not self.icon then
      self.icon, self.icon_color = devicons.get_icon_color_by_filetype(
        vim.bo.filetype,
        { default = true }
      )
    end
  end,
  provider = function(self)
    self:fetch()
    return self.icon
  end,
  hl = function(self)
    if not self.icon_color then
      self:fetch()
    end
    return { fg = self.icon_color }
  end,
  lazy = true,
  update = {
    "User ExtraLazy",
    "BufEnter",
    "TermEnter",
    "TermClose",
    "OptionSet filetype",
    "ModeChanged",
  },
}

local i = 0
local FileType = {
  provider = function(_self)
    i = i + 1
    -- vim.print(i)
    return vim.bo.filetype
  end,
  hl = function()
    return { fg = hl.fetch_attr("LspInlayHint", "fg") }
  end,
  lazy = true,
  update = {
    "User VeryLazy",
    "BufEnter",
    "TermEnter",
    "TermClose",
    "OptionSet filetype",
    "ModeChanged",
  },
}

local Space = {
  provider = " ",
}

local opts = {
  left = {
    Mode,
  },
  center = {
    Mode,
  },
  right = {
    Devicon,
    Space,
    FileType,
    Space,
    Location,
  },
}

-- local group = vim.api.nvim_create_augroup("aoiwhfawfi", { clear = true })

require("lazyline").setup(opts)

return opts
