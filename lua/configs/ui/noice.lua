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

require("noice").setup({
  status = {
    progress = {
      event = "lsp",
      kind = "progress",
    },
  },
  presets = {
    long_message_to_split = true,
    inc_rename = true,
  },
  smart_move = {
    enabled = true,
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
      enabled = true,
      view = "mini",
    },
    signature = {
      enabled = true,
      auto_open = {
        enabled = true,
        trigger = true,
        luasnip = true,
        throttle = 50,
      },
      opts = {},
    },
    hover = {
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
        title = "python",
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
          { find = "%d+L, %d+B written$" },
          { find = "^%d+ change[s]?; before #%d+" },
          { find = "^%d+ change[s]?; after #%d+" },
        },
      },
      view = "mini",
      opts = {
        stop = true,
        skip = true,
      },
    },
  },
})

local noice_progress = require("noice.lsp.progress")
-- hack to allow progress to accept custom client names

---@diagnostic disable-next-line: duplicate-set-field
function noice_progress.progress(_, msg, info)
  local id = info.client_id .. "." .. msg.token

  local message = noice_progress._progress[id]
  if not message then
    local client = vim.lsp.get_client_by_id(info.client_id)
    -- should not happen, but it does for some reason
    if not client then
      return
    end
    message = require("noice.message")("lsp", "progress")
    message.opts.progress = {
      client_id = info.client_id,
      ---@type string
      client = info.client
        or (
          client and client.name
          or ("lsp-" .. (info.client_id or info.client or "progress"))
        ),
    }
    noice_progress._progress[id] = message
  end

  message.opts.progress =
    vim.tbl_deep_extend("force", message.opts.progress, msg.value)
  message.opts.progress.id = id

  if msg.value.kind == "end" then
    if message.opts.progress.percentage then
      message.opts.progress.percentage = 100
    end
    vim.defer_fn(function()
      noice_progress.close(id)
    end, 100)
  end

  noice_progress.update()
end
