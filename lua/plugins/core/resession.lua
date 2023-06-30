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

      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
          -- Only load the session if nvim was started with no args
          if vim.fn.argc(-1) == 0 then
            -- Save these to a different directory, so our manual sessions don't get polluted
            resession.load(cwd(), { dir = "dirsession", silence_errors = true })
          end
        end,
      })
      vim.api.nvim_create_autocmd("VimLeavePre", {
        callback = function()
          resession.save_tab("last", { notify = false })
          local name = cwd(-1, tabnr(curtab()))
          resession.save_tab(name, { dir = "dirsession", notify = false })
        end,
      })
    end,
  },
  {
    "ahmedkhalf/project.nvim",
    lazy = false,
    config = function()
      require("project_nvim").setup({
        patterns = {
          ".git",
          "Cargo.toml",
          "package.json",
          "Makefile",
        },
        scope_chdir = "tab",
      })
      require("telescope").load_extension("projects")
    end,
  },
  {
    "tiagovla/scope.nvim",
    config = function()
      require("scope").setup({})
      require("telescope").load_extension("scope")
    end,
  },
}
