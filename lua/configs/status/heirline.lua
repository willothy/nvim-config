local icons = require("willothy.ui.icons")

local get_hex = require("willothy.lib.hl").get

local A = function(self)
  local o = vim.deepcopy(self)
  o.hl = function()
    local col = require("willothy.ui.mode").get_color()
    return {
      fg = col.fg,
      bg = col.fg,
    }
  end
  return o
end

local B = function(self)
  local o = vim.deepcopy(self)
  o.hl = function()
    return {
      fg = get_hex("StatusLine", "fg"),
      bg = get_hex("StatusLine", "bg"),
    }
  end
  return o
end

local Separator = {
  Left = {
    provider = icons.blocks.left[4],
  },
  Right = {
    provider = icons.blocks.right.half,
  },
}

local Align = { provider = "%=" }

local Space = setmetatable({
  provider = " ",
}, {
  __index = function(_, k)
    if type(k) == "number" then
      return {
        provider = string.rep(" ", k),
      }
    end
  end,
})

local Mode = {
  A(Separator.Left),
  {
    provider = function()
      return string.char(require("willothy.ui.mode").get_short_name():byte(1))
    end,
    hl = function()
      local col = require("willothy.ui.mode").get_color()
      return {
        fg = "#0f0f0f",
        bg = col.fg,
      }
    end,
    update = {
      "User",
      pattern = {
        "VeryLazy",
        "UpdateHeirlineComponents",
      },
    },
  },
  A(Separator.Right),
}

local Location = {
  -- B(Space),
  {
    update = {
      "User",
      pattern = {
        "UpdateHeirlineLocation",
        "UpdateHeirlineComponents",
      },
      callback = function(self)
        self.pos = vim.api.nvim_win_get_cursor(0)
      end,
    },
    -- hl = function()
    --   local col = willothy.ui.mode.get_color()
    --   return {
    --     fg = get_hex("StatusLine", "bg"),
    --     bg = col.fg,
    --   }
    -- end,
    provider = function(self)
      if not self.pos then
        self.update.callback(self)
      end
      return string.format("%03d:%02d", self.pos[1], self.pos[2])
    end,
  },
  Space,
  {
    static = {
      -- sbar = { "▁", "▂", "▃", "▄", "▅", "▆", "▇", "█" },

      sbar = { "▔", "🮂", "🮃", "▀", "🮄", "🮅", "🮆", "█" },
    },
    provider = function(self)
      local curr_line = vim.api.nvim_win_get_cursor(0)[1]
      local lines = vim.api.nvim_buf_line_count(0)
      local i = math.floor((curr_line - 1) / lines * #self.sbar) + 1
      return string.rep(self.sbar[i], 3)
    end,
    hl = function()
      local col = require("willothy.ui.mode").get_color()
      return {
        -- bg = get_hex("StatusLine", "bg"),
        fg = col.fg,
      }
    end,
  },
}

local Env = function(var)
  return (
    B({
      provider = function(self)
        if not self.val then
          self.val = os.getenv(var)
        end
        return (self.val and self.val ~= "") and self.val .. " " or ""
      end,
      condition = function(self)
        if not self.init then
          return true
        end
        return self.val ~= nil
      end,
      update = {
        "BufEnter",
        "DirChanged",
        callback = function(self)
          self.val = os.getenv(var)
        end,
      },
    })
  )
end

local Filetype = (
  B({
    provider = function(self)
      return self.val or ""
    end,
    condition = function()
      return vim.bo.filetype ~= "" or vim.api.nvim_buf_get_name(0) ~= ""
    end,
    static = {
      buftypes = {
        [""] = true,
        ["terminal"] = true,
      },
      -- excplicitly allow filetypes regardless of buftype
      filetypes = {
        ["oil"] = true,
      },
    },
    update = {
      "User",
      pattern = {
        "UpdateHeirlineComponents",
      },
      callback = function(self)
        -- if
        --   not self.buftypes[vim.bo.buftype]
        --   and not self.filetypes[vim.bo.filetype]
        -- then
        --   return
        -- end
        self.val = vim.bo.filetype ~= "" and vim.bo.filetype
          or vim.fn.fnamemodify(
            string.lower(vim.api.nvim_buf_get_name(0)),
            ":t"
          )
      end,
    },
    Space,
  })
)

local Devicon = {
  provider = function(self)
    return self.icon and self.icon or ""
  end,
  hl = function(self)
    return { fg = self.icon_color }
  end,
  condition = function(self)
    return package.loaded["nvim-web-devicons"] ~= nil
  end,
  update = {
    "User",
    pattern = {
      "UpdateHeirlineComponents",
    },
    callback = function(self)
      -- if
      --   not self.buftypes[vim.bo.buftype]
      --   and not self.filetypes[vim.bo.filetype]
      -- then
      --   return
      -- end
      local filename = vim.fn.expand("%")
      local extension = vim.fn.fnamemodify(filename, ":e")
      local devicons = require("nvim-web-devicons")
      self.icon, self.icon_color = devicons.get_icon_color(filename, extension)
      if not self.icon then
        self.icon, self.icon_color = devicons.get_icon_color_by_filetype(
          vim.bo.filetype,
          { default = false }
        )
      end
    end,
  },
  Space,
}

local Recording = (
  B({
    provider = function(self)
      return self.status or ""
    end,
    update = {
      "User",
      pattern = {
        "MacroStateChanged",
      },
      callback = function(self)
        self.status = require("willothy.macros").statusline()
        vim.cmd.redrawstatus()
      end,
    },
    {
      condition = function(self)
        return self.status ~= nil and self.status ~= ""
      end,
      Space,
    },
  })
)

local Git = (
  B({
    update = {
      "User",
      pattern = {
        "UpdateHeirlineComponents",
        "GitSignsUpdate",
      },
      callback = function(self)
        if self:update_buf() then
          self:fetch()
        end
      end,
    },
    static = {
      update_buf = function(self)
        local curwin = vim.api.nvim_get_current_win()
        local main_wins = require("edgy.editor").list_wins().main or {}
        if
          vim.iter(main_wins):find(function(win)
            return win == curwin
          end) ~= nil
        then
          self.buf = vim.api.nvim_get_current_buf()
          return true
        else
          self.buf = nil
        end
      end,
      fetch = function(self)
        if self.buf and not vim.api.nvim_buf_is_valid(self.buf) then
          self:update_buf()
        end
        if self.buf and vim.api.nvim_buf_is_valid(self.buf) then
          self.status_dict = vim.b[self.buf].gitsigns_status_dict
        else
          self.status_dict = vim.b.gitsigns_status_dict
        end
        -- get head one of these two ways, since both can be inconsistent
        -- at times and I want to show the branch even if I can't show
        -- diff information
        local heads = {
          self.status_dict and self.status_dict.head,
          vim.g.gitsigns_head,
        }
        if
          not self.head
          or (
            (heads[1] and heads[1] ~= "" and heads[1] ~= self.head)
            or (heads[2] and heads[2] ~= "" and heads[2] ~= self.head)
          )
        then
          if heads[1] and heads[1] ~= "" then
            self.head = heads[1]
          elseif heads[2] and heads[2] ~= "" then
            self.head = heads[2]
          else
            self.head = nil
          end
        end
      end,
      added = function(self)
        return self.status_dict and self.status_dict.added or 0
      end,
      removed = function(self)
        return self.status_dict and self.status_dict.removed or 0
      end,
      modified = function(self)
        return self.status_dict and self.status_dict.changed or 0
      end,
    },
    {
      provider = function(self)
        local head = self.head
        if not head or head == "" then
          return ""
        end
        return string.format("%s %s", icons.git.branch, head)
      end,
      condition = function(self)
        return self.head ~= nil
      end,
      hl = "StatusLine",
      Space,
    },
    {
      provider = function(self)
        return string.format("%s %s", icons.git.diff.added, self:added())
      end,
      condition = function(self)
        return self:added() > 0
      end,
      hl = "DiffAdd",
      Space,
    },
    {
      provider = function(self)
        return string.format("%s %s", icons.git.diff.removed, self:removed())
      end,
      condition = function(self)
        return self:removed() > 0
      end,
      hl = "DiffDelete",
      Space,
    },
    {
      provider = function(self)
        return string.format("%s %s", icons.git.diff.modified, self:modified())
      end,
      condition = function(self)
        return self:modified() > 0
      end,
      hl = "DiffChange",
      Space,
    },
  })
)

local Sesh = Env("SESH_NAME")

local DAPMessages = {
  condition = function()
    return package.loaded["dap"] and require("dap").session()
  end,
  provider = function()
    return " " .. require("dap").status()
  end,
  hl = "Debug",
  Space,
}

local Overseer = {
  condition = function()
    return package.loaded["overseer"] ~= nil
  end,
  init = function(self)
    self.overseer = require("overseer")
    self.tasks = self.overseer.task_list
    self.STATUS = self.overseer.constants.STATUS
  end,
  static = {
    symbols = {
      ["FAILURE"] = " 󰲼 ",
      ["CANCELED"] = " 󱄊 ",
      ["SUCCESS"] = " 󰦕 ",
      ["RUNNING"] = " 󰦖 ", --" 省",
    },
    colors = {
      ["FAILURE"] = "OverseerFAILURE",
      ["CANCELED"] = "OverseerCANCELED",
      ["SUCCESS"] = "OverseerSUCCESS",
      ["RUNNING"] = "OverseerRUNNING",
    },
  },
  {
    condition = function(self)
      return #self.tasks.list_tasks() > 0
    end,
    {
      provider = function(self)
        local tasks_by_status = self.overseer.util.tbl_group_by(
          self.tasks.list_tasks({ unique = true }),
          "status"
        )

        for _, status in ipairs(self.STATUS.values) do
          local status_tasks = tasks_by_status[status]
          if self.symbols[status] and status_tasks then
            self.color = self.colors[status]
            return self.symbols[status]
          end
        end
      end,
      hl = function(self)
        local hl = vim.api.nvim_get_hl(0, { name = self.color, link = false })
        return { fg = hl and require("willothy.lib.hl").hex(hl.fg) or "gray" }
      end,
    },
  },
}

local StatusLine = {
  {
    Mode,
    Space,
    Git,
    Overseer,
  },
  Align,
  {
    DAPMessages,
    Recording,
    Devicon,
    Filetype,
    Sesh,
    Location,
  },
}

require("heirline").setup({
  statusline = StatusLine,
})

local event = require("willothy.lib.event")

event.on({
  "ModeChanged",
  "BufEnter",
}, function()
  event.emit("UpdateHeirlineComponents")
end)

event.on(
  {
    "BufLeave",
    "DirChanged",
    "WinEnter",
    "TermLeave",
    "TermEnter",
    "LspAttach",
    "ColorScheme",
    "ColorSchemePre",
    "VeryLazy",
  },
  vim.schedule_wrap(require("willothy.lib.fn").throttle(function()
    event.emit("UpdateHeirlineComponents")
  end, 250))
)

event.on({
  "BufEnter",
  "BufNew",
  "CursorMoved",
  "CursorMovedI",
}, function()
  event.emit("UpdateHeirlineLocation")
end)

event.on("ColorScheme", function()
  require("heirline.highlights").reset_highlights()
  require("heirline.highlights").clear_colors()
end)
