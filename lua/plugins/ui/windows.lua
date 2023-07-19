return {
  {
    "nvim-focus/focus.nvim",
    config = function()
      local disable = {
        filetype = {
          "neo-tree",
          "SidebarNvim",
          "Trouble",
          "terminal",
        },
      }
      local focus = require("focus")

      focus.setup({
        ui = {
          cursorline = false,
          signcolumn = false,
          winhighlight = false,
        },
      })
      local group = vim.api.nvim_create_augroup("focus_ft", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        group = group,
        callback = function()
          if vim.tbl_contains(disable.filetype, vim.bo.filetype) then
            vim.b.focus_disable = true
          end
        end,
        desc = "Disable focus autoresize for FileType",
      })
    end,
    event = "VeryLazy",
  },
  {
    "echasnovski/mini.animate",
    opts = {
      cursor = { enable = false },
      scroll = { enable = true },
      open = { enable = false },
      close = { enable = false },
    },
    event = "VeryLazy",
  },
  {
    "yorickpeterse/nvim-window",
    config = true,
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
}
