return {
  {
    "stevearc/resession.nvim",
    config = function()
      local curtab = vim.api.nvim_get_current_tabpage
      local tabnr = vim.api.nvim_tabpage_get_number
      local bufname = vim.api.nvim_buf_get_name
      local cwd = vim.fn.getcwd
      local resession = require("resession")

      resession.setup({
        autosave = {
          enabled = true,
          interval = 300,
          notify = false,
        },
        tab_buf_filter = function(tabpage, bufnr)
          return vim.startswith(bufname(bufnr), cwd(-1, tabnr(tabpage)))
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
        resession.load(cwd(), { dir = "dirsession", silence_errors = true })
      end
      vim.api.nvim_create_autocmd("VimLeavePre", {
        callback = function()
          resession.save_tab("last", { notify = false })
          local name = cwd(-1, tabnr(curtab()))
          resession.save_tab(name, { dir = "dirsession", notify = false })
        end,
      })
    end,
    event = "VeryLazy",
  },
  {
    "ahmedkhalf/project.nvim",
    event = "VeryLazy",
    config = function()
      require("project_nvim").setup({
        patterns = {
          ".git",
          "Cargo.toml",
        },
        scope_chdir = "tab",
      })
    end,
  },
  {
    "tiagovla/scope.nvim",
    config = true,
    event = "VimEnter",
  },
  {
    "pynappo/tabnames.nvim",
    config = function()
      local tabnames = require("tabnames")
      tabnames.setup({
        auto_suggest_names = true,
        default_tab_name = tabnames.tab_name_presets.short_tab_cwd,
        experimental = {
          session_support = false,
        },
      })
    end,
  },
}
