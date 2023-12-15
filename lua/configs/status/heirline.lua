local p = require("minimus").hex
local icons = willothy.icons

local conditions = require("heirline.conditions")
local get_hex = willothy.hl.get

local AB = function(self)
  local o = vim.deepcopy(self)
  o.hl = function()
    local col = willothy.utils.mode.get_color()
    return {
      fg = col.fg,
      bg = get_hex("TabLine", "bg"),
    }
  end
  return o
end

local B = function(self)
  local o = vim.deepcopy(self)
  o.hl = function()
    return {
      fg = get_hex("Normal", "fg"),
      bg = get_hex("TabLine", "bg"),
    }
  end
  return o
end

local C = function(self)
  local o = vim.deepcopy(self)
  o.hl = function()
    return { fg = get_hex("TabLine", "fg"), bg = p.none }
  end
  return o
end

local transformed = {}
---@param path string?
---@return string
local function make_cwd(path)
  local cwd = path or vim.fn.getcwd(-1)
  if not cwd then
    return ""
  end

  if transformed[cwd] then
    return transformed[cwd]
  end

  local rel = vim.fn.fnamemodify(cwd, ":~")
  local short = vim.fn.pathshorten(rel, 3)
  ---@cast short string
  transformed[cwd] = short
  return short
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
  AB(Separator.Left),
  B({
    provider = function()
      return willothy.utils.mode.get_name()
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
  }),
  AB(Separator.Right),
}

local Location = {
  AB(Separator.Left),
  B(Space),
  B({
    update = {
      "User",
      pattern = {
        "UpdateHeirlinePosition",
        "UpdateHeirlineComponents",
      },
      callback = function(self)
        self.line = vim.fn.line(".")
        self.col = vim.fn.col(".")
        self.maxline = vim.fn.line("$")
      end,
    },
    provider = function(self)
      if not self.line then
        self.update.callback(self)
      end
      return math.floor((self.line / self.maxline) * 100)
        .. "%%/"
        .. string.format("%d:%d", self.maxline, self.col)
    end,
  }),
  B(Space),
  AB(Separator.Right),
}

local copilot_init = false
-- selene: allow(unused_variable)
local Copilot = (
  C({
    init = vim.schedule_wrap(function(self)
      self.ready = false

      if not copilot_init then
        copilot_init = true
        return
      elseif not self.ready then
        require("copilot.api").register_status_notification_handler(
          function(data)
            self.status = data or {}
            if self.status.status == nil or self.status.status == "" then
              self.status.status = "InProgress"
            end
          end
        )
        self.ready = true
      end

      self.status = {
        status = "Normal",
      }
    end),
    provider = function(self)
      if not self.ready then
        return ""
      end
      local icon = icons.git.copilot_err
      if self.status.status == "InProgress" then
        icon = require("noice.util.spinners").spin("dots") or "\\"
      elseif self.status.status == "Warning" then
        icon = icons.git.copilot_warn
      elseif self.status.status == "Normal" then
        icon = icons.git.copilot
      end

      return icon .. " "
    end,
  })
)

local Env = function(var)
  return (
    C({
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
  C({
    provider = function(_self)
      return vim.bo.filetype ~= "" and vim.bo.filetype
        or vim.fn.fnamemodify(string.lower(vim.api.nvim_buf_get_name(0)), ":t")
    end,
    update = {
      "BufEnter",
      "OptionSet",
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
  condition = function()
    return package.loaded["nvim-web-devicons"] ~= nil
  end,
  static = {
    fetch = function(self)
      -- if self.ft == vim.bo.filetype then
      --   return
      -- end
      -- self.icon = nil
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
  update = {
    "User",
    pattern = {
      "UpdateHeirlineComponents",
    },
    callback = function(self)
      self:fetch()
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
    Space,
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
      local buf = require("plenary.path")
        :new(vim.api.nvim_buf_get_name(0))
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
        local update = vim.schedule_wrap(function()
          willothy.event.emit("UpdateHeirlineComponents")
        end)
        harpoon:extend({
          ADD = update,
          REMOVE = update,
          REORDER = update,
        })
        self._init = true
      end
    end,
  },
}

local Recording = (
  C({
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
  C({
    update = {
      "User",
      pattern = {
        "UpdateHeirlineComponents",
        "GitSignsAttach",
        "GitSignsUpdate",
      },
      callback = function(self)
        local curwin = vim.api.nvim_get_current_win()
        if
          vim.iter(require("edgy.editor").list_wins().main):find(function(win)
            return win == curwin
          end) ~= nil
        then
          self.buf = vim.api.nvim_get_current_buf()
          self:fetch()
        end
      end,
    },
    static = {
      fetch = function(self)
        if self.buf then
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
        if not self.status_dict then
          self:fetch()
        end
        return self.status_dict and self.status_dict.removed or 0
      end,
      modified = function(self)
        if not self.status_dict then
          self:fetch()
        end
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
      -- hl = { fg = p.red },
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
      -- hl = { fg = p.lemon_chiffon },
      hl = "DiffChange",
      Space,
    },
  })
)

local WorkDir = (
  C({
    provider = function()
      return make_cwd()
    end,
    on_click = {
      callback = function()
        willothy.fs.browse(vim.fn.getcwd(-1))
      end,
      name = "__heirline_workdir_click",
    },
    update = {
      "User",
      pattern = "UpdateHeirlineComponents",
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

local SessionName = {
  condition = function(self)
    if package.loaded.resession and not self.m then
      self.m = require("resession")
    end
    return self.m and (self.m.get_current() or self.m.is_loading()) or false
  end,
  provider = function(self)
    local name = self.m.get_current()
    if name and name:match("/") then
      name = vim.fn.fnamemodify(name, ":~")
    end
    return make_cwd(name) or require("noice.util.spinners").spin("dots9")
  end,
}

---@diagnostic disable-next-line: unused-local
-- selene: allow(unused_variable)
local SignColumn = {
  provider = "%2.2s",
}

---@diagnostic disable-next-line: unused-local
-- selene: allow(unused_variable)
local NumberColumn = {
  provider = "%=%{v:relnum?v:relnum:v:lnum}",
  hl = function(self)
    if
      vim.v.relnum == 0
      and self.winnr
        == vim.api.nvim_win_get_number(tonumber(vim.g.actual_curwin) or 0)
    then
      return "CurrentMode"
    else
      return "LineNr"
    end
  end,
}

local ffi = require("ffi")

-- Get direct fold information from Neovim
ffi.cdef([[
	typedef struct {} Error;
	typedef struct {} win_T;
	typedef struct {
		int start;  // line number where deepest fold starts
		int level;  // fold level, when zero other fields are N/A
		int llevel; // lowest level that starts in v:lnum
		int lines;  // number of lines from v:lnum to end of closed fold
	} foldinfo_T;
	foldinfo_T fold_info(win_T* wp, int lnum);
	win_T *find_window_by_handle(int Window, Error *err);
	int compute_foldcolumn(win_T *wp, int col);
]])

---@diagnostic disable-next-line: unused-local
-- selene: allow(unused_variable)
local FoldColumn = {
  fallthrough = false,
  init = function(self)
    local wp = ffi.C.find_window_by_handle(0, ffi.new("Error")) -- get window handler
    self.width = ffi.C.compute_foldcolumn(wp, 0) -- get foldcolumn width
    -- get fold info of current line
    self.foldinfo = self.width > 0 and ffi.C.fold_info(wp, vim.v.lnum)
      or { start = 0, level = 0, llevel = 0, lines = 0 }
    self.closed = self.foldinfo.lines > 0
  end,
  static = {
    foldopen = icons.fold.open,
    foldclosed = icons.fold.closed,
    foldsep = " ",
  },
  {
    provider = function(self)
      return self.foldopen .. " "
    end,
    condition = function(self)
      local first_level = self.foldinfo.level
        - self.width
        - (self.closed and 1 or 0)
        + 1
      if first_level < 1 then
        first_level = 1
      end
      return self.foldinfo.start == vim.v.lnum
        and first_level + 1 > self.foldinfo.llevel
    end,
    on_click = {
      callback = function()
        vim.print("close click")
        local mouse = vim.fn.getmousepos()
        if not mouse then
          return
        end
        local curwin = vim.api.nvim_get_current_win()
        local cursor = vim.api.nvim_win_get_cursor(curwin)
        vim.api.nvim_set_current_win(mouse.winid)
        vim.api.nvim_win_set_cursor(mouse.winid, { mouse.line, 0 })

        vim.cmd("normal! zc")

        vim.api.nvim_set_current_win(curwin)
        vim.api.nvim_win_set_cursor(curwin, cursor)
      end,
      name = "__heirline_fold_close_click",
    },
  },
  {
    provider = function(self)
      return self.foldclosed .. " "
    end,
    condition = function(self)
      return self.foldinfo.lines > 0
    end,
    on_click = {
      callback = function()
        vim.print("open click")
        local mouse = vim.fn.getmousepos()
        if not mouse then
          return
        end
        local curwin = vim.api.nvim_get_current_win()
        local cursor = vim.api.nvim_win_get_cursor(curwin)
        vim.api.nvim_set_current_win(mouse.winid)
        vim.api.nvim_win_set_cursor(mouse.winid, { mouse.line, 0 })

        vim.cmd("normal! zo")

        vim.api.nvim_set_current_win(curwin)
        vim.api.nvim_win_set_cursor(curwin, cursor)
      end,
      name = "__heirline_fold_open_click",
    },
  },
  {
    provider = function(self)
      return self.foldsep .. " "
    end,
  },
}

local Overseer = {
  condition = function(self)
    return package.loaded["overseer"] ~= nil
  end,
  init = function(self)
    self.overseer = require("overseer")
    self.tasks = self.overseer.task_list
    self.STATUS = self.overseer.constants.STATUS
  end,
  static = {
    symbols = {
      ["FAILURE"] = "  ",
      ["CANCELED"] = "  ",
      ["SUCCESS"] = "  ",
      ["RUNNING"] = " 省",
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

local Truncate = { provider = "%<" }

local function Center(group)
  return C({
    Align,
    group,
    Align,
  })
end

local function Right(group)
  return C({
    -- {
    --   provider = function()
    --     local len = vim.fn.strcharlen(make_cwd())
    --     local size = math.floor(vim.o.columns / 2) - math.floor(len / 2)
    --     return "%"
    --       .. size - 1
    --       .. "."
    --       .. size --
    --       .. "("
    --   end,
    -- },
    -- {
    --   provider = "%(",
    -- },
    group,
    -- {
    --   provider = "%)",
    -- },
  })
end

local Left = function(group)
  return C({
    -- {
    --   provider = function()
    --     local len = vim.fn.strcharlen(make_cwd())
    --     local size = math.floor(vim.o.columns / 2) - math.floor(len / 2)
    --     return "%-" .. size - 1 .. "("
    --     -- return "%-1("
    --     -- return "%1("
    --   end,
    -- },
    -- {
    --   provider = "%-(",
    -- },
    group,
    -- {
    --   provider = "%)",
    -- },
    -- Truncate,
  })
end

local StatusLine = {
  Left({
    Mode,
    Space,
    Git,
    Harpoon,
    Overseer,
  }),
  Center({
    {
      fallthrough = false,
      -- SessionName,
      -- WorkDir,
    },
  }),
  Right({
    DAPMessages,
    Recording,
    Devicon,
    Filetype,
    Sesh,
    Location,
  }),
}

-- local StatusColumn = {
--   SignColumn,
--   NumberColumn,
--   Space,
--   FoldColumn,
--   Space,
-- }

require("heirline").setup({
  statusline = StatusLine,
  -- statuscolumn = {}
  -- statuscolumn = StatusColumn,
})

willothy.event.on({
  "DirChanged",
  "ModeChanged",
  "BufEnter",
  "WinEnter",
  "TermLeave",
  "BufEnter",
  "TermEnter",
  "LspAttach",
  "ColorScheme",
  "VeryLazy",
}, function()
  willothy.event.emit("UpdateHeirlineComponents")
end)

willothy.event.on({
  "BufEnter",
  "BufNew",
  "CursorMoved",
  "CursorMovedI",
}, function()
  willothy.event.emit("UpdateHeirlinePosition")
end)

willothy.event.on("ColorScheme", function()
  require("heirline").setup({
    statusline = C(StatusLine),
  })
end)
