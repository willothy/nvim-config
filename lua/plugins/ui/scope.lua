local au = vim.api.nvim_create_augroup("murmur_au", { clear = true })

return {
  {
    "willothy/anyline.nvim",
    dir = "~/projects/lua/anyline.nvim/",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    event = "VeryLazy",
    opts = {
      highlight = "WinSeparator",
      context_highlight = "Function",
      ft_ignore = {
        "NvimTree",
        "TelescopePrompt",
        "Trouble",
        "SidebarNvim",
        "neo-tree",
        "noice",
        "terminal",
      },
    },
  },
  {
    "nyngwang/murmur.lua",
    event = "VeryLazy",
    config = function()
      require("murmur").setup({
        exclude_filetypes = {
          "harpoon",
          "neo-tree",
          "noice",
          "SidebarNvim",
          "terminal",
          "Trouble",
        },
        callbacks = {
          function()
            vim.api.nvim_exec_autocmds(
              "User",
              { pattern = "MurmurDiagnostics" }
            )
            vim.w.diag_shown = false
          end,
        },
      })
      -- To create IDE-like no blinking diagnostic message with `cursor` scope. (should be paired with the callback above)
      vim.api.nvim_create_autocmd({ "CursorHold", "InsertLeave" }, {
        group = au,
        pattern = "*",
        callback = function()
          -- skip when a float-win already exists.
          if vim.w.diag_shown then return end

          -- open float-win when hovering on a cursor-word.
          if vim.w.cursor_word ~= "" then
            local buf = vim.diagnostic.open_float({
              scope = "cursor",
              close_events = { "InsertEnter", "User MurmurDiagnostics" },
            })
            vim.api.nvim_create_autocmd("WinClosed", {
              group = au,
              buffer = buf,
              once = true,
              callback = function() vim.w.diag_shown = false end,
            })
            vim.w.diag_shown = true
          else
            vim.w.diag_shown = false
          end
        end,
      })

      -- To create special cursorword coloring for the colortheme `typewriter-night`.
      -- remember to change it to the name of yours.
      vim.api.nvim_set_hl(
        0,
        "murmur_cursor_rgb",
        vim.api.nvim_get_hl(
          0,
          { id = vim.api.nvim_get_hl_id_by_name("MiniCursorword") }
        )
      )
    end,
  },
}
