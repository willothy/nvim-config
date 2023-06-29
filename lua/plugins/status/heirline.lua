local p = require("minimus.palette").hex
local icons = require("willothy.icons")
local mode_colors = {
  normal = {
    { fg = p.raisin_black, bg = p.turquoise },
    { fg = p.text, bg = p.gunmetal },
    { fg = p.cool_gray, bg = p.none },
  },
  insert = {
    { fg = p.raisin_black, bg = p.pale_azure },
    { fg = p.text, bg = p.gunmetal },
    { fg = p.cool_gray, bg = p.none },
  },
  visual = {
    { fg = p.raisin_black, bg = p.lemon_chiffon },
    { fg = p.text, bg = p.gunmetal },
    { fg = p.cool_gray, bg = p.none },
  },
  replace = {
    { fg = p.raisin_black, bg = p.lavender_pink },
    { fg = p.text, bg = p.gunmetal },
    { fg = p.cool_gray, bg = p.none },
  },
  command = {
    { fg = p.raisin_black, bg = p.peach },
    { fg = p.text, bg = p.gunmetal },
    { fg = p.cool_gray, bg = p.none },
  },
  inactive = {
    { fg = p.blueGray3, bg = p.gunmetal },
    { fg = p.blueGray3, bg = p.gunmetal },
    { fg = p.blueGray3, bg = p.none },
  },
}

local mode_map = {
  n = mode_colors.normal,
  i = mode_colors.insert,
  v = mode_colors.visual,
  V = mode_colors.visual,
  ["\22"] = mode_colors.visual,
  c = mode_colors.command,
  s = mode_colors.visual,
  S = mode_colors.visual,
  ["\19"] = mode_colors.visual,
  R = mode_colors.replace,
  r = mode_colors.replace,
  ["!"] = mode_colors.command,
  t = mode_colors.command,
}

local function handler(f, name)
  return {
    callback = f,
    name = name or ("handler_" .. math.ceil(math.random() * 100)),
  }
end

local function heirline()
  local utils = require("heirline.utils")
  local conditions = require("heirline.conditions")

  local with = {
    __index = function(self, k)
      if k == "with" then
        return function(Component, opts) return utils.clone(Component, opts) end
      else
        return rawget(self, k)
      end
    end,
  }
  local Component = function(init) return setmetatable(init, with) end

  local hl = {
    A = function(_self)
      local mode = vim.fn.mode(1):sub(1, 1)
      return mode_map[mode][1]
    end,
    ANOBG = function(_self)
      local mode = vim.fn.mode(1):sub(1, 1)
      return {
        fg = mode_map[mode][1].bg,
        bg = "none",
      }
    end,
    AB = function(_self)
      local mode = vim.fn.mode(1):sub(1, 1)
      return {
        fg = mode_map[mode][1].bg,
        bg = mode_map[mode][2].bg,
      }
    end,
    B = function(_self)
      local mode = vim.fn.mode(1):sub(1, 1)
      return mode_map[mode][2]
    end,
    BC = function(_self)
      local mode = vim.fn.mode(1):sub(1, 1)
      return {
        fg = mode_map[mode][2].bg,
        bg = mode_map[mode][3].bg,
      }
    end,
    C = function(_self)
      local mode = vim.fn.mode(1):sub(1, 1)
      return mode_map[mode][3]
    end,
    NONE = { fg = "none", bg = "none", style = "none" },
  }
  setmetatable(hl, {
    __call = function(_self, component, highlight)
      return setmetatable(
        utils.clone(component, {
          hl = highlight,
        }),
        with
      )
    end,
  })

  local separators = {
    left = function(highlight)
      return Component({
        provider = icons.separators.circle.left,
        hl = highlight,
      })
    end,
    right = function(highlight)
      return Component({
        provider = icons.separators.circle.right,
        hl = highlight,
      })
    end,
  }

  local BG = function(component)
    return {
      hl = hl.C,
      component,
    }
  end

  local Align = { provider = "%=" }
  local Space = function(count)
    return setmetatable({ provider = string.rep(" ", count) }, with)
  end

  local Mode = Component({
    static = {
      mode_names = {
        n = "Normal",
        no = "Normal?",
        nov = "Normal?",
        noV = "Normal?",
        ["no\22"] = "Normal?",
        niI = "I-Normal",
        niR = "R-Normal",
        niV = "V-Normal",
        nt = "T-Normal",
        v = "Visual",
        vs = "Visual-S",
        V = "V-Line",
        Vs = "V-Line-S",
        ["\22"] = "V-Block",
        ["\22s"] = "V-Block-S",
        s = "Select",
        S = "S-Line",
        ["\19"] = "S-Block",
        i = "Insert",
        ic = "C-Insert",
        ix = "X-Insert",
        R = "Replace",
        Rc = "C-Replace",
        Rx = "X-Replace",
        Rv = "V-Replace",
        Rvc = "VC-Replace",
        Rvx = "VX-Replace",
        c = "Command",
        cv = "Vim Ex",
        r = "...",
        rm = "More",
        ["r?"] = "?",
        ["!"] = "!",
        t = "Terminal",
      },
    },
    init = function(self)
      self.mode = vim.fn.mode(1) -- :h mode()
    end,
    provider = function(self)
      return "%2( " .. self.mode_names[self.mode] .. " %)"
    end,
    hl = hl.A,
    update = {
      "ModeChanged",
      pattern = "*:*",
      callback = vim.schedule_wrap(function() vim.cmd("redrawstatus") end),
    },
  })

  local Location = Component({
    init = function(self)
      self.line = vim.fn.line(".")
      self.col = vim.fn.col(".")
      self.maxline = vim.fn.line("$")
    end,
    provider = function(self)
      local s = math.floor((self.line / self.maxline) * 100)
        .. "%%/"
        .. string.format("%d:%d", self.maxline, self.col)
      local width = s:len() + math.max(#tostring(self.col), 2)

      return "%" .. width .. "=" .. s .. "%" .. width .. ")"
    end,
    hl = hl.A,
  })

  local Copilot = Component({
    init = function(self)
      self.status = {
        status = "",
      }
      require("copilot.api").register_status_notification_handler(
        function(data) self.status = data or { status = "InProgress" } end
      )
    end,
    provider = function(self)
      local icon = icons.git.copilot_err
      if self.status.status == "InProgress" then
        icon = require("noice.util.spinners").spin("dots")
          or icons.git.copilot_warn
      elseif self.status.status == "Warning" then
        icon = icons.git.copilot_warn
      elseif self.status.status == "Normal" then
        icon = icons.git.copilot
      end
      return icon .. " "
    end,
    hl = hl.C,
  })

  local Env = function(var)
    return Component({
      provider = function()
        local val = os.getenv(var)
        return (val and val ~= "") and val .. " " or ""
      end,
      hl = hl.C,
    })
  end

  local Filetype = Component({
    provider = function(_self)
      return vim.bo.filetype ~= "" and vim.bo.filetype
        or vim.fn.fnamemodify(string.lower(vim.api.nvim_buf_get_name(0)), ":t")
    end,
    hl = hl.C,
  })

  local Devicon = Component({
    init = function(self)
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
    provider = function(self) return self.icon and self.icon or "" end,
    hl = function(self) return { fg = self.icon_color } end,
  })

  local Harpoon = Component({
    init = function(self)
      self.h = require("harpoon.mark")
      self.current = self.h.get_current_index()
      self.nfiles = self.h.get_length()
      self.h.on("changed", function()
        self.nfiles = self.h.get_length()
        self.current = self.h.get_current_index()
      end)
    end,
    provider = function(self)
      if self.nfiles == nil or self.nfiles == 0 then
        return " " .. icons.misc.hook_disabled
      elseif self.current == nil then
        return " " .. icons.misc.hook_disabled .. " " .. self.nfiles
      end
      return " " .. icons.misc.hook .. " " .. self.current .. "/" .. self.nfiles
    end,
    on_click = handler(function()
      local buf = vim.api.nvim_buf_get_name(0)
      require("harpoon.mark").toggle_file(buf)
      require("harpoon").save()
    end),
  })

  local Git = Component({
    static = {},
    condition = conditions.is_git_repo,
    init = function(self)
      self.status_dict = vim.b.gitsigns_status_dict
      self.has_changes = self.status_dict.added ~= 0
        or self.status_dict.removed ~= 0
        or self.status_dict.changed ~= 0
      self.added = function() return self.status_dict.added or 0 end
      self.removed = function() return self.status_dict.removed or 0 end
      self.modified = function() return self.status_dict.changed or 0 end
    end,
    hl = hl.C,
    {
      -- git branch name
      provider = function(self)
        local head = self.status_dict.head
        if not head or head == "" then head = "<empty>" end
        return string.format("%s %s ", icons.git.branch, head)
      end,
      hl = { fg = p.cool_gray },
    },
    {
      -- git diff added
      provider = function(self)
        if self.added() > 0 then
          return string.format("%s %s", icons.git.diff.added, self.added())
            .. ((self.modified() > 0 or self.removed() > 0) and " " or "")
        else
          return ""
        end
      end,
      hl = { fg = p.pale_turquoise },
    },
    {
      -- git diff removed
      provider = function(self)
        if self.removed() > 0 then
          return string.format("%s %s", icons.git.diff.removed, self.removed())
            .. (self.modified() > 0 and " " or "")
        else
          return ""
        end
      end,
      hl = { fg = p.red },
    },
    {
      -- git diff changed
      provider = function(self)
        if self.modified() > 0 then
          return string.format(
            "%s %s",
            icons.git.diff.modified,
            self.modified()
          )
        else
          return ""
        end
      end,
      hl = { fg = p.lemon_chiffon },
    },
  })

  ---@diagnostic disable-next-line: unused_variable
  -- selene: allow(unused_variable)
  local Filename = Component({
    provider = function(_self)
      local filename = vim.fn.expand("%:t")
      filename = filename == "" and "[No Name]" or filename
      return filename
    end,
    hl = hl.C,
  })

  -- Statusline item format
  --
  -- Usually, the statusline consists of multiple printf style % items for showing various info about current file, e.g., %F is used to show the full path of current file. The complete format for items are as follows:
  --
  -- %-0{minWidth}.{maxWidth}{item}
  --
  -- '-' means to align the item to the left instead of right (the default).
  -- '0' is the leading zeros for items that return numeric numbers and is overridden by -.
  -- 'minWidth' and 'maxWidth' decide the min and max length of the item to be shown.
  -- All fields are optional except {item} itself.
  local StatusLine = {
    {
      -- Left side
      separators.left(hl.ANOBG),
      hl(Mode, hl.A),
      separators.right(hl.ANOBG),
      hl({
        Space(1),
        {
          Git,
          condition = conditions.is_git_repo,
        },
      }, hl.C),
      Harpoon,
      Space(1),
      {
        provider = "%<",
      },
    },
    Align,
    {
      -- Align
      provider = function()
        local content = ""

        return content
      end,
      hl = hl.ANOBG,
    },
    Align,
    {
      -- Right side
      {
        provider = "%>",
      },
      hl({
        Space(1),
        Devicon,
        Space(1),
        -- Filename,
        Filetype,
        Space(1),
        Copilot,
        Space(1),
        Env("SESH_NAME"),
      }, hl.C),
      separators.left(hl.ANOBG),
      hl(Location, hl.A),
      separators.right(hl.ANOBG),
    },
  }

  return {
    statusline = BG(StatusLine),
  }
end

return {
  {
    "rebelot/heirline.nvim",
    config = function()
      require("heirline").setup(heirline())
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup(
          "heirline_colorscheme_reset",
          { clear = true }
        ),
        callback = function() require("heirline").setup(heirline()) end,
      })
    end,
  },
}
