local p = require("minimus").hex
local icons = willothy.icons

local conditions = require("heirline.conditions")
local get_hex = willothy.hl.get

-- selene: allow(unused_variable)
local A = function(self)
  self.hl = function()
    return willothy.utils.mode.get_color()
  end
  return self
end

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

-- selene: allow(unused_variable)
local Icon = function(icon, hl)
  return {
    provider = icon,
    hl = hl,
  }
end

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
      "BufEnter",
      "BufNew",
      "CursorMoved",
      "CursorMovedI",
      callback = function(self)
        self.line = vim.fn.line(".")
        self.col = vim.fn.col(".")
        self.maxline = vim.fn.line("$")
      end,
    },
    provider = function(self)
      if not self.line then
        return ""
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
    pattern = { "ExtraLazy", "UpdateHeirlineComponents" },
    callback = function(self)
      self:fetch()
    end,
  },
  Space,
}

local Harpoon = {
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
      require("harpoon.mark").toggle_file(buf)
      require("harpoon").save()
    end,
    name = "__heirline_harpoon_click",
  },
  update = {
    "User",
    pattern = {
      "ExtraLazy",
      "UpdateHarpoonStatus",
      "UpdateHeirlineComponents",
    },
    callback = function(self)
      local harpoon = require("harpoon.mark")
      self.current = harpoon.get_current_index()
      if not self._init then
        self.nfiles = harpoon.get_length()
        harpoon.on("changed", function()
          self.nfiles = harpoon.get_length()
        end)
        self._init = true
      else
        return true
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
        "ExtraLazy",
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
      pattern = { "ExtraLazy", "UpdateHeirlineComponents" },
      callback = function(self)
        self:fetch()
      end,
    },
    condition = conditions.is_git_repo,
    static = {
      fetch = function(self)
        self.status_dict = vim.b.gitsigns_status_dict
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
        local head = self.status_dict.head
        if not head or head == "" then
          head = "<empty>"
        end
        return string.format("%s %s", icons.git.branch, head)
      end,
      condition = function(self)
        return self.status_dict
          and self.status_dict.head
          and self.status_dict.head ~= ""
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
      -- hl = "DiffAdd",
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
    provider = function(self)
      return self.cwd or ""
    end,
    on_click = {
      callback = function(self)
        willothy.fs.browse(self.cwd)
      end,
      name = "__heirline_workdir_click",
    },
    update = {
      "User",
      pattern = "UpdateHeirlineComponents",
      callback = function(self)
        self.cwd = vim.fn.fnamemodify(vim.fn.getcwd(-1), ":~")
      end,
    },
  })
)

local Sesh = Env("SESH_NAME")

local DAPMessages = {
  condition = function()
    return require("dap").session() ~= nil
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
    return self.m and self.m.get_current() or self.m.is_loading() or false
  end,
  provider = function(self)
    local name = self.m.get_current()
    if name and name:match("/") then
      name = vim.fn.fnamemodify(name, ":~")
    end
    return name or require("noice.util.spinners").spin("dots9")
  end,
}

local function Center(group)
  return {
    Align,
    group,
    Align,
  }
end

local function Right(group)
  return {
    {
      provider = function()
        return "%0"
          .. math.floor(vim.o.columns / 2) - 10
          .. "."
          .. math.floor(vim.o.columns / 2) - 10
          .. "("
      end,
    },
    group,
    {
      provider = "%)",
    },
  }
end

local Left = function(group)
  return {
    {
      provider = function()
        return "%-"
          .. math.floor(vim.o.columns / 2) - 10
          .. "."
          .. math.floor(vim.o.columns / 2) - 10
          .. "("
      end,
    },
    group,
    {
      provider = "%)",
    },
  }
end

local StatusLine = {
  Left({
    Mode,
    Space,
    Git,
    Harpoon,
  }),
  Center({
    {
      fallthrough = false,
      SessionName,
      WorkDir,
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

require("heirline").setup({
  statusline = C(StatusLine),
})

local update = function()
  vim.api.nvim_exec_autocmds("User", { pattern = "UpdateHeirlineComponents" })
end

vim.api.nvim_create_autocmd({
  "DirChanged",
  "ModeChanged",
  "BufEnter",
  "TermEnter",
  "LspAttach",
  "ColorScheme",
}, {
  group = vim.api.nvim_create_augroup(
    "heirline_update_cmds",
    { clear = true }
  ),
  callback = update,
})

vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup(
    "heirline_colorscheme_reset",
    { clear = true }
  ),
  callback = function()
    require("heirline").setup({
      statusline = C(StatusLine),
    })
  end,
})
