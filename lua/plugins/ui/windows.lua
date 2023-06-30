return {
  {
    "nvim-focus/focus.nvim",
    branch = "refactor",
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
    lazy = true,
    event = "VeryLazy",
  },
  {
    "echasnovski/mini.animate",
    opts = {
      cursor = { enable = false },
      scroll = { enable = false },
      open = { enable = false },
      close = { enable = false },
    },
  },
  {
    "yorickpeterse/nvim-window",
    config = function()
      local w = require("nvim-window")
      w.setup({})
    end,
  },
}
