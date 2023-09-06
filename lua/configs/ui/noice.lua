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
        style = "none",
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
        width = 80,
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
