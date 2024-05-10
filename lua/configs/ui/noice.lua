local border_style = {
  left = { " ", "NoiceCmdlinePopupBorder" },
  right = { " ", "NoiceCmdlinePopupBorder" },
  top = { "▀", "NoiceCmdlinePopupBorder" },
  top_left = { "▀", "NoiceCmdlinePopupBorder" },
  top_right = { "▀", "NoiceCmdlinePopupBorder" },
  bottom = { "▄", "NoiceCmdlinePopupBorder" },
  bottom_left = { "▄", "NoiceCmdlinePopupBorder" },
  bottom_right = { "▄", "NoiceCmdlinePopupBorder" },
}

local require = require("noice.util.lazy")

local Util = require("noice.util")
local View = require("noice.view")

---@class NoiceFidgetOptions
---@field timeout integer
---@field reverse? boolean
local defaults = { timeout = 5000 }

---@class FidgetView: NoiceView
---@field active table<number, NoiceMessage>
---@field super NoiceView
---@field handles table<number, ProgressHandle>
---@field timers table<number, uv_timer_t>
---@diagnostic disable-next-line: undefined-field
local FidgetView = View:extend("MiniView")

function FidgetView:init(opts)
  FidgetView.super.init(self, opts)
  self.active = {}
  self.timers = {}
  self._instance = "view"
  self.handles = {}
end

function FidgetView:update_options()
  self._opts = vim.tbl_deep_extend("force", defaults, self._opts)
end

---@param message NoiceMessage
function FidgetView:can_hide(message)
  if message.opts.keep and message.opts.keep() then
    return false
  end
  return not Util.is_blocking()
end

function FidgetView:autohide(id)
  if not id then
    return
  end
  if not self.timers[id] then
    self.timers[id] = vim.loop.new_timer()
  end
  self.timers[id]:start(self._opts.timeout, 0, function()
    if not self.active[id] then
      return
    end
    if not self:can_hide(self.active[id]) then
      return self:autohide(id)
    end
    self.active[id] = nil
    self.timers[id] = nil
    vim.schedule(function()
      self:update()
    end)
  end)
end

function FidgetView:show()
  for _, message in ipairs(self._messages) do
    -- we already have debug info,
    -- so make sure we dont regen it in the child view
    message._debug = true
    self.active[message.id] = message
    self:autohide(message.id)
  end
  self:clear()
  self:update()
end

function FidgetView:dismiss()
  self:clear()
  self.active = {}
  self:update()
end

function FidgetView:update()
  ---@type NoiceMessage[]
  local active = vim.tbl_values(self.active)
  table.sort(
    active,
    ---@param a NoiceMessage
    ---@param b NoiceMessage
    function(a, b)
      local ret = a.id < b.id
      if self._opts.reverse then
        return not ret
      end
      return ret
    end
  )
  for _, message in pairs(active) do
    require("fidget").notify(
      message:content(),
      message.level or vim.log.levels.INFO,
      {
        id = message.id,
        group = "noice",
        annote = message.opts.title,
      }
    )
  end
end

function FidgetView:hide()
  -- for _, handle in pairs(self.handles) do
  --   handle:finish()
  -- end
end

package.loaded["noice.view.backend.fidget"] = FidgetView

require("noice").setup({
  status = {
    -- progress = {
    --   event = "lsp",
    --   kind = "progress",
    -- },
  },
  presets = {
    long_message_to_split = true,
    inc_rename = true,
  },
  smart_move = {
    enabled = true,
  },
  redirect = {
    view = "fidget",
  },
  views = {
    split = {
      win_options = {
        winhighlight = "Normal:Normal",
      },
    },
    mini = {
      win_options = {
        winblend = 0,
      },
    },
    cmdline_popup = {
      position = {
        row = "35%",
        col = "50%",
      },
      border = {
        style = border_style,
        padding = { 0, 0 },
      },
      win_options = {
        -- winblend = 100,
        winhighlight = {
          Normal = "NormalFloat",
          FloatBorder = "NormalBorder",
        },
        cursorline = false,
      },
      size = {
        width = "auto",
        height = "auto",
      },
    },
    hover = {
      silent = true,
      border = {
        style = border_style,
        padding = { 0, 0 },
      },
    },
    popup = {
      border = {
        style = border_style,
        padding = { 0, 0 },
      },
      win_options = {
        winhighlight = {
          Normal = "NormalFloat",
          FloatBorder = "NormalFloatInv",
        },
      },
    },
    popupmenu = {
      relative = "editor",
      position = {
        row = "40%",
        col = "50%",
      },
      size = {
        width = 79,
        height = 10,
      },
      border = {
        style = border_style,
        padding = { 0, 0 },
      },
      win_options = {
        winhighlight = {
          Normal = "NormalFloat",
          FloatBorder = "NormalFloatInv",
        },
      },
    },
  },
  lsp = {
    --override markdown rendering so that **cmp** and other plugins use **Treesitter**
    override = {
      ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
      ["vim.lsp.util.stylize_markdown"] = true,
      ["cmp.entry.get_documentation"] = true,
    },
    progress = {
      enabled = false,
      view = "mini",
    },
    signature = {
      enabled = true,
      auto_open = {
        enabled = true,
        trigger = true,
        throttle = 50,
      },
      opts = {},
    },
    hover = {
      silent = true,
      enabled = true,
      border = {
        style = border_style,
        padding = { 0, 0 },
      },
    },
  },
  cmdline = {
    view = "cmdline_popup",
    format = {
      search_down = {
        view = "cmdline",
      },
      search_up = {
        view = "cmdline",
      },
      python = {
        pattern = { "^:%s*pyt?h?o?n?%s+", "^:%s*py?t?h?o?n%s*=%s*" },
        icon = "󰌠",
        lang = "python",
        title = " python ",
      },
    },
  },
  popupmenu = {
    enabled = true,
    backend = "nui",
  },
  messages = {
    enabled = true, -- enables the Noice messages UI
    view = "notify", -- default view for messages
    view_error = "notify", -- view for errors
    view_warn = "notify", -- view for warnings
    view_history = "messages", -- view for :messages
    view_search = "virtualtext", -- view for search count messages. Set to `false` to disable
  },
  notify = {
    enabled = true,
  },
  routes = {
    {
      filter = {
        any = {
          -- this filters messages to be shown by fidget
          { find = "^[^%s]+%s(%d+)L, (%d+)B%s+%[w%]$" },
        },
      },
      view = "fidget",
      opts = {
        stop = true,
        skip = true, -- change to false to show
        format = {
          "{message}",
        },
      },
    },
  },
})
