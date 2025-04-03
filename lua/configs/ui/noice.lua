local require = require("noice.util.lazy")

---@diagnostic disable-next-line: missing-fields
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
  views = {
    split = {},
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
        style = "solid",
      },
      win_options = {
        winhighlight = {
          Normal = "NormalFloat",
        },
      },
      size = {
        width = "auto",
        height = "auto",
      },
    },
    hover = {
      silent = true,
      border = {
        style = "solid",
        padding = { 0, 0 },
      },
    },
    popup = {
      border = {
        style = "solid",
        padding = { 0, 0 },
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
        style = "solid",
        padding = { 0, 0 },
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
        style = "solid",
        padding = { 0, 0 },
      },
    },
  },
  cmdline = {
    view = "cmdline_popup",
    -- view = "cmdline",
    format = {
      cmdline = {
        pattern = "^:",
        icon = "",
        -- icon = ":",
        lang = "vim",
      },
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
  routes = {},
})
