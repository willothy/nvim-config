vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = function()
    for k, v in pairs({
      print = function(...)
        Snacks.debug.inspect(...)
        return ...
      end,
    }) do
      vim[k] = v
    end

    local Snacks = Snacks

    Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
    Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
    Snacks.toggle
      .option("relativenumber", { name = "Relative Number" })
      :map("<leader>uL")
    Snacks.toggle.diagnostics():map("<leader>ud")
    Snacks.toggle.inlay_hints():map("<leader>uh")
    Snacks.toggle.indent():map("<leader>ui")
    Snacks.toggle.dim():map("<leader>uD")
    Snacks.toggle.zoom():map("<leader>uz")
    Snacks.toggle.scroll():map("<leader>uS")
    Snacks.toggle.profiler():map("<leader>uP")
    Snacks.toggle.profiler_highlights():map("<leader>up")
  end,
})

---@param self snacks.win
local function add_borders(self)
  local win = assert(self.win)

  local macro = vim.api.nvim_get_hl(0, {
    name = "Macro",
    link = false,
    create = false,
  })

  local border = vim.api.nvim_get_hl(0, {
    name = "FloatBorder",
    link = false,
    create = false,
  })

  vim.api.nvim_set_hl(0, "SnacksInputBorder", {
    fg = macro.fg,
    bg = border.bg,
  })

  vim.wo[win].winhl = "FloatBorder:SnacksInputBorder"
end

local indent_disabled = {
  markdown = true,
  txt = true,
  text = true,
  help = true,
}

local Snacks = require("snacks")

Snacks.setup({
  toggle = {},
  image = {},
  profiler = {},
  dashboard = {
    enabled = true,

    sections = {
      {
        align = "center",
        text = {
          { "Neovim", hl = "Identifier" },
          { " :: ", hl = "Comment" },
          { tostring(vim.version()), hl = "Identifier" },
        },
      },
      {
        align = "center",
        section = "startup",
      },
    },
  },
  layout = {},
  win = {},
  statuscolumn = {
    left = { "mark", "sign", "git" },
    right = { "fold" },
    folds = {
      open = true,
    },
  },
  picker = {
    prompt = "  ",
    sources = {
      files = {
        ---@diagnostic disable-next-line: missing-fields
        matcher = {
          frecency = true,
          sort_empty = true,
        },
      },
      projects = {
        confirm = function(...)
          return Snacks.picker.actions.load_session(...)
        end,
      },
    },
    ui_select = false,
    actions = require("trouble.sources.snacks").actions,
    layouts = {
      default = {
        layout = {
          box = "horizontal",
          width = 0.8,
          min_width = 120,
          height = 0.8,
          border = "none",
          {
            box = "vertical",
            border = "solid",
            title = "{title} {live} {flags}",
            {
              win = "input",
              height = 1,
              border = "bottom",
              on_win = add_borders,
            },
            { win = "list", border = "none" },
          },
          {
            win = "preview",
            title = "{preview}",
            border = {
              " ",
              " ",
              " ",
              " ",
              " ",
              " ",
              " ",
              "│",
            },
            width = 0.5,
          },
        },
      },
      vertical = {
        layout = {
          backdrop = false,
          width = 0.5,
          min_width = 80,
          height = 0.8,
          min_height = 30,
          box = "vertical",
          border = "vpad",
          title = "{title} {live} {flags}",
          title_pos = "center",
          {
            win = "input",
            height = 1,
            border = "bottom",
            on_win = add_borders,
          },
          { win = "list", border = "none" },
          {
            win = "preview",
            title = "{preview}",
            height = 0.4,
            -- border = "vpad",
          },
        },
      },
    },
    win = {
      list = {
        border = "none",
      },
      preview = {
        border = "none",
      },
      input = {
        keys = {
          ["<C-t>"] = {
            "trouble_open",
            mode = { "n", "i" },
          },
        },
      },
    },
  },
  terminal = {
    bo = {},
  },
  notifier = {
    enabled = true,
    style = "compact",
    notification = {
      bo = {
        filetype = "markdown",
      },
    },
  },
  words = {},
  indent = {
    enabled = true,
    indent = {
      char = "▏",
      hl = "WinSeparator",
    },
    scope = {
      char = "▏",
      hl = "Function",
      only_current = true,
    },
    animate = {
      style = "out",
      fps = 120,
    },
    filter = function(buf)
      return vim.g.snacks_indent ~= false
        and vim.b[buf].snacks_indent ~= false
        and vim.bo[buf].buftype == ""
        and not indent_disabled[vim.bo[buf].filetype]
    end,
  },
  styles = {
    dashboard = {
      relative = "editor",
      layout = {
        layout = {
          border = "none",
        },
      },
    },
    notification = {
      relative = "editor",
      ft = "markdown",
      wo = {
        wrap = true,
      },
      bo = {
        filetype = "markdown",
      },
    },
    float = {
      relative = "editor",
      border = "solid",
    },
    input = {
      relative = "editor",
      border = "single",
    },
    minimal = {
      relative = "editor",
      border = "solid",
    },
    scratch = {
      relative = "editor",
      border = "single",
    },
    zen = {
      relative = "editor",
      border = "none",
    },
    zoom_indicator = {
      relative = "win",
      border = "none",
    },
  },
})

Snacks.picker.actions.load_session = function(picker)
  local item = picker:current()
  picker:close()
  if not item then
    return
  end
  local dir = item.file:gsub("/", "_")

  local resession = require("resession")

  local function hook_fn()
    resession.remove_hook("post_load", hook_fn)
  end

  resession.add_hook("post_load", hook_fn)

  resession.load(dir, {
    -- silence_errors = true,
    reset = true,
  })
end
