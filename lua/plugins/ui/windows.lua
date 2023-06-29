return {
  -- {
  --   "anuvyklack/windows.nvim",
  --   dependencies = {
  --     "anuvyklack/middleclass",
  --   },
  --   config = function()
  --     require("windows").setup({
  --       autowidth = {
  --         enable = true,
  --       },
  --       animation = {
  --         enable = false,
  --       },
  --     })
  --   end,
  --   lazy = true,
  --   event = "VeryLazy",
  -- },
  {
    "nvim-focus/focus.nvim",
    branch = "refactor",
    config = function()
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
          if
            vim.tbl_contains({
              "neo-tree",
              "SidebarNvim",
              "Trouble",
              "terminal",
              "TelescopePrompt",
              "",
            }, vim.bo.filetype)
          then
            vim.b.focus_disable = true
          end
        end,
        desc = "Disable focus autoresize for FileType",
      })
      vim.api.nvim_create_autocmd("WinEnter", {
        group = group,
        callback = function(_)
          if vim.tbl_contains({ "nofile", "terminal" }, vim.bo.buftype) then
            vim.b.focus_disable = true
          end
        end,
        desc = "Disable focus autoresize for BufType",
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
