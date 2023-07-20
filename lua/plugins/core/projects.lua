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
          if vim.bo[bufnr].buftype ~= "" then return false end
          local bufhidden = vim.bo[bufnr].bufhidden
          local name = vim.api.nvim_buf_get_name(bufnr)
          tabpage = vim.api.nvim_tabpage_get_number(tabpage)

          if bufhidden == "wipe" or vim.bo[bufnr].buflisted == false then
            return false
          end

          return vim.startswith(name, vim.fn.getcwd(-1, tabpage))
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
          vim.fn.getcwd(-1),
          { dir = "dirsession", silence_errors = false }
        )
      end
      vim.api.nvim_create_autocmd("VimLeavePre", {
        callback = function()
          resession.save_tab("last", { notify = false })
          local saved = {}
          vim.iter(vim.api.nvim_list_tabpages()):each(function(tab)
            local cwd = vim.fn.getcwd(-1, tab)
            if not saved[cwd] then
              resession.save_tab(cwd, { dir = "dirsession", notify = false })
              saved[cwd] = true
            end
          end)
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
    event = "User ExtraLazy",
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
    event = "User ExtraLazy",
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
