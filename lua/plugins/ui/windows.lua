return {
  {
    "nvim-focus/focus.nvim",
    dir = "~/projects/lua/focus.nvim/",
    config = function()
      local disable = {
        ["neo-tree"] = true,
        ["SidebarNvim"] = true,
        ["Trouble"] = true,
        ["terminal"] = true,
        ["dapui_console"] = true,
        ["dapui_watches"] = true,
        ["dapui_stacks"] = true,
        ["dapui_breakpoints"] = true,
        ["dapui_scopes"] = true,
        ["dap-repl"] = true,
        ["NeogitStatus"] = true,
        ["NeogitLogView"] = true,
        ["NeogitPopup"] = true,
        ["NeogitCommitMessage"] = true,
      }
      local focus = require("focus")

      focus.setup({
        ui = {
          cursorline = false,
          signcolumn = false,
          winhighlight = false,
        },
        autoresize = {
          -- width = 180,
          -- minwidth = 200,
          animation = {
            enable = true,
            easing = "linear",
          },
        },
      })
      require("willothy.modenr")
      local group = vim.api.nvim_create_augroup("focus_ft", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        group = group,
        callback = function(ev)
          local ft = vim.bo[ev.buf].filetype
          if disable[ft] then vim.w.focus_disable = true end
        end,
        desc = "Disable focus autoresize for FileType",
      })
    end,
    event = "VeryLazy",
  },
  {
    "echasnovski/mini.animate",
    -- enabled = false,
    opts = {
      scroll = { enable = false },
      cursor = { enable = false },
      open = { enable = false },
      close = { enable = false },
    },
    event = "VeryLazy",
  },
  {
    "willothy/nvim-window-picker",
    dir = "~/projects/lua/nvim-window-picker/",
    event = "User ExtraLazy",
    config = function()
      require("window-picker").setup({
        show_prompt = false,
        hint = "floating-big-letter",
        filter_rules = {
          autoselect_one = false,
          include_current_win = false,
          bo = {
            filetype = {
              "noice",
            },
            buftype = {
              "nofile",
              "nowrite",
            },
          },
        },
        selection_chars = "asdfwertzxcv",
        create_chars = "hjkl",
        picker_config = {
          floating_big_letter = {
            font = {
              -- pick chars
              w = "w",
              a = "a",
              s = "s",
              d = "d",
              f = "f",
              e = "e",
              r = "r",
              t = "t",
              z = "z",
              x = "x",
              c = "c",
              v = "v",
              -- create chars
              h = "h",
              j = "j",
              k = "k",
              l = "l",
            },
            window = {
              config = {
                border = "none",
              },
              options = {
                winhighlight = "NormalFloat:TabLineSel,FloatBorder:TabLineSel",
              },
            },
          },
        },
      })
    end,
  },
  {
    "mrjones2014/smart-splits.nvim",
    config = function()
      require("smart-splits").setup({
        at_edge = "wrap",
        resize_mode = {
          hooks = {
            on_leave = require("bufresize").register,
          },
        },
        ignore_events = {
          "WinResized",
          "BufWinEnter",
          "BufEnter",
          "WinEnter",
        },
      })
    end,
    event = "VeryLazy",
  },
  {
    "kwkarlwang/bufresize.nvim",
    event = "VeryLazy",
    register = {
      trigger_events = { "BufWinEnter", "WinEnter" },
    },
    resize = {
      trigger_events = { "VimResized" },
    },
  },
  {
    "tummetott/winshift.nvim",
    branch = "not_triggering_optionset_event",
    config = true,
    cmd = "WinShift",
  },
  {
    "willothy/winborder.nvim",
    -- dir = "~/projects/lua/winborder.nvim/",
    config = true,
    enabled = false,
    event = "VeryLazy",
  },
  {
    "stevearc/stickybuf.nvim",
    opts = {},
    event = "User ExtraLazy",
  },
}
