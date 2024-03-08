local p = require("minimus").hex
local icons = willothy.ui.icons

local get_hex = willothy.hl.get

local A = function(self)
  local o = vim.deepcopy(self)
  o.hl = function()
    local col = willothy.ui.mode.get_color()
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

-- local transformed = {}
-- ---@param path string?
-- ---@return string
-- local function make_cwd(path)
--   local cwd = path or vim.fn.getcwd(-1)
--   if not cwd then
--     return ""
--   end
--
--   if transformed[cwd] then
--     return transformed[cwd]
--   end
--
--   local rel = vim.fn.fnamemodify(cwd, ":~")
--   local short = vim.fn.pathshorten(rel, 3)
--   ---@cast short string
--   transformed[cwd] = short
--   return short
-- end

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
      return willothy.ui.mode.get_short_name()
    end,
    hl = function()
      local col = willothy.ui.mode.get_color()
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
        "HydraEnter",
        "HydraLeave",
      },
    },
  },
  A(Separator.Right),
}

local Location = {
  A(Separator.Left),
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
    hl = function()
      local col = willothy.ui.mode.get_color()
      return {
        fg = get_hex("StatusLine", "bg"),
        bg = col.fg,
      }
    end,
    provider = function(self)
      if not self.pos then
        self.update.callback(self)
      end
      return string.format("%03d:%02d", self.pos[1], self.pos[2])
    end,
  },
  -- B(Space),
  A(Separator.Right),
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
  static = {
    -- buftypes = {
    --   [""] = true,
    --   ["terminal"] = true,
    -- },
    -- filetypes = {
    --   ["oil"] = true,
    -- },
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

local Harpoon = {
  condition = function()
    return package.loaded["harpoon"]
  end,
  {
    fallthrough = false,
    {
      provider = icons.misc.hook,
      condition = function(self)
        return self.nfiles ~= nil and self.current ~= nil
      end,
      Space,
    },
    {
      provider = icons.misc.hook_disabled,
      Space,
    },
  },
  {
    condition = function(self)
      return self.nfiles ~= nil and self.current ~= nil
    end,
    {
      provider = function(self)
        return self.current
      end,
    },
    { provider = "/" },
  },
  {
    provider = function(self)
      return self.nfiles
    end,
    condition = function(self)
      return self.nfiles ~= nil and self.nfiles > 0
    end,
  },
  on_click = {
    callback = function()
      local buf = vim.api.nvim_buf_get_name(0)
      local path = require("plenary.path"):new(buf)
      local list = require("harpoon"):list("files")

      local row, col = unpack(vim.api.nvim_win_get_cursor(0))

      local item = {
        value = path:make_relative(vim.uv.cwd()),
        context = {
          row = row,
          col = col,
        },
      }

      if list:length() == list:append(item):length() then
        list:remove(item)
      end
    end,
    name = "__heirline_harpoon_click",
  },
  update = {
    "User",
    pattern = {
      "UpdateHarpoonStatus",
      "UpdateHeirlineComponents",
    },
    callback = function(self)
      local harpoon = require("harpoon")
      local list = harpoon:list("files")

      local bufnr = 0
      if vim.bo.filetype == "harpoon" then
        -- keep current harpoon file while menu is open
        -- since the alternate file will be the buffer open
        -- in the previous window
        bufnr = vim.fn.bufnr("#") --[[@as integer]]
      end

      local buf = require("plenary.path")
        :new(vim.api.nvim_buf_get_name(bufnr))
        :make_relative(vim.uv.cwd())
      local idx
      local items = list:display()
      for i, v in ipairs(items) do
        if v == buf then
          idx = i
          break
        end
      end
      self.current = idx
      self.nfiles = list:length()
      if not self._init then
        local update = function()
          willothy.event.emit("UpdateHeirlineComponents")
        end
        local schedule = vim.schedule_wrap(update)
        harpoon:extend({
          ADD = schedule,
          REMOVE = schedule,
          REORDER = schedule,
          UI_CREATE = update,
        })
        self._init = true
      end
    end,
  },
}

local Recording = (
  B({
    provider = function(self)
      return self.status or ""
    end,
    condition = function()
      return package.loaded["NeoComposer"]
    end,
    update = {
      "User",
      pattern = {
        "NeoComposerRecordingSet",
        "NeoComposerPlayingSet",
        "NeoComposerDelaySet",
      },
      callback = function(self)
        self.status = require("NeoComposer.ui").status_recording()
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
      hl = { fg = p.cool_gray },
      Space,
    },
    {
      provider = function(self)
        return string.format("%s %s", icons.git.diff.added, self:added())
      end,
      condition = function(self)
        return self:added() > 0
      end,
      hl = { fg = p.pale_turquoise },
      Space,
    },
    {
      provider = function(self)
        return string.format("%s %s", icons.git.diff.removed, self:removed())
      end,
      condition = function(self)
        return self:removed() > 0
      end,
      hl = { fg = p.red },
      Space,
    },
    {
      provider = function(self)
        return string.format("%s %s", icons.git.diff.modified, self:modified())
      end,
      condition = function(self)
        return self:modified() > 0
      end,
      hl = { fg = p.lemon_chiffon },
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
        return { fg = hl and willothy.hl.hex(hl.fg) or "gray" }
      end,
    },
  },
}

local StatusLine = {
  {
    Mode,
    Space,
    Git,
    Harpoon,
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

willothy.event.on({
  "ModeChanged",
  "HydraEnter",
  "HydraLeave",
  "BufEnter",
}, function()
  willothy.event.emit("UpdateHeirlineComponents")
end)

willothy.event.on(
  {
    "BufLeave",
    "DirChanged",
    "WinEnter",
    "TermLeave",
    "TermEnter",
    "LspAttach",
    "ColorScheme",
    "VeryLazy",
  },
  vim.schedule_wrap(willothy.fn.throttle(function()
    willothy.event.emit("UpdateHeirlineComponents")
  end, 250))
)

willothy.event.on({
  "BufEnter",
  "BufNew",
  "CursorMoved",
  "CursorMovedI",
}, function()
  willothy.event.emit("UpdateHeirlineLocation")
end)

willothy.event.on("ColorScheme", function()
  require("heirline.highlights").reset_highlights()
  require("heirline.highlights").clear_colors()
end)
