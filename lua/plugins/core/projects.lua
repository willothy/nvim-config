return {
  {
    "stevearc/resession.nvim",
    config = function()
      local resession = require("resession")

      resession.setup({
        extensions = {
          scope = {
            enable_in_tab = true,
          },
        },
        autosave = {
          enabled = true,
          interval = 300,
          notify = false,
        },
        tab_buf_filter = function(tabpage, bufnr)
          return vim.startswith(
            vim.api.nvim_buf_get_name(bufnr),
            vim.fn.getcwd(-1, vim.api.nvim_tabpage_get_number(tabpage))
          )
        end,
        buf_filter = function(bufnr)
          local filetype = vim.bo[bufnr].filetype
          if
            filetype == "gitcommit"
            or filetype == "gitrebase"
            or vim.bo[bufnr].bufhidden == "wipe"
          then
            return false
          end
          local buftype = vim.bo[bufnr].buftype
          if buftype == "help" then return true end
          if buftype ~= "" and buftype ~= "acwrite" then return false end
          if vim.api.nvim_buf_get_name(bufnr) == "" then return false end
          return vim.bo[bufnr].buflisted
        end,
      })

      -- Only load the session if nvim was started with no args
      if vim.fn.argc(-1) == 0 then
        -- Save these to a different directory, so our manual sessions don't get polluted
        resession.load(
          vim.fn.getcwd(),
          { dir = "dirsession", silence_errors = false }
        )
      end
      vim.api.nvim_create_autocmd("VimLeavePre", {
        callback = function()
          resession.save("last", { notify = false })
          -- resession.save_tab(
          --   vim.fn.getcwd(-1),
          --   { dir = "dirsession", notify = false }
          -- )
          vim.iter(vim.api.nvim_list_tabpages()):each(function(tab)
            local win = vim.api.nvim_tabpage_get_win(tab)
            vim.api.nvim_win_call(win, function()
              local cwd = vim.fn.getcwd(-1)
              resession.save_tab(cwd, { dir = "dirsession", notify = false })
            end)
          end)
          -- resession.save_all({ notify = false })
        end,
      })
    end,
    dependencies = {
      "ahmedkhalf/project.nvim",
      "tiagovla/scope.nvim",
    },
    event = "User ExtraLazy",
  },
  {
    "ahmedkhalf/project.nvim",
    name = "project_nvim",
    event = "VeryLazy",
    opts = {
      detection_methods = { "lsp", "pattern" },
      patterns = {
        ".git",
        "Cargo.toml",
        "Makefile",
        "package.json",
        "^.config/",
        "^~/projects/*/",
      },
      exclude_dirs = {
        "~/.local/",
        "~/.cargo/",
      },
      ignore_lsp = { "null-ls", "savior" },
      silent_chdir = false,
      show_hidden = true,
      scope_chdir = "tab",
    },
  },
  {
    "tiagovla/scope.nvim",
    config = true,
    event = "UiEnter",
    -- event = "User ExtraLazy",
  },
  {
    "willothy/savior.nvim",
    config = true,
    event = "User ExtraLazy",
  },
  -- {
  --   "pynappo/tabnames.nvim",
  --   event = "User ExtraLazy",
  --   config = function()
  --     local tabnames = require("tabnames")
  --     tabnames.setup({
  --       auto_suggest_names = true,
  --       default_tab_name = tabnames.tab_name_presets.short_tab_cwd,
  --       experimental = {
  --         session_support = false,
  --       },
  --     })
  --   end,
  -- },
}
