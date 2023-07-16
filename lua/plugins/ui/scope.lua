local au = vim.api.nvim_create_augroup("murmur_au", { clear = true })

return {
  {
    "willothy/anyline.nvim",
    dir = "~/projects/lua/anyline.nvim/",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    event = "VeryLazy",
    config = function()
      require("anyline").setup({
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
      })

      vim.api.nvim_create_autocmd({ "BufEnter", "LspAttach", "CursorHold" }, {
        group = au,
        pattern = "*",
        once = true,
        callback = vim.schedule_wrap(function()
          local tab = vim.api.nvim_get_current_tabpage()
          local curwin = vim.api.nvim_get_current_win()
          local visited = {}
          for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
            local bufnr = vim.api.nvim_win_get_buf(win)
            vim.api.nvim_win_call(win, function()
              visited[bufnr] = true
              require("anyline.cache").get_cache(bufnr)
              require("anyline.markager").remove_all_marks(bufnr)
              require("anyline.setter").set_marks(bufnr)
              if win == curwin then
                require("anyline.context").show_context(bufnr)
              end
            end)
          end
        end),
      })
    end,
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
      vim.api.nvim_create_autocmd("CursorHold", {
        group = au,
        pattern = "*",
        callback = function()
          -- skip when a float-win already exists.
          if vim.w.diag_shown then return end

          -- open float-win when hovering on a cursor-word.
          if vim.w.cursor_word ~= "" then
            local buf = vim.diagnostic.open_float({
              scope = "cursor",
              close_events = {
                "InsertEnter",
                "User MurmurDiagnostics",
              },
            })

            vim.api.nvim_create_autocmd({ "WinClosed" }, {
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
