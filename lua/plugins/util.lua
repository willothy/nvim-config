return {
  {
    "ellisonleao/glow.nvim",
    config = true,
    cmd = "Glow",
  },
  {
    "eandrju/cellular-automaton.nvim",
    cmd = "CellularAutomaton",
  },
  {
    "rafcamlet/nvim-luapad",
    cmd = "Luapad",
    config = true,
  },
  {
    "Aasim-A/scrollEOF.nvim",
    config = true,
    event = "User ExtraLazy",
  },
  {
    "lambdalisue/suda.vim",
    cmd = { "SudaRead", "SudaWrite" },
  },
  {
    "jackMort/ChatGPT.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    cmd = {
      "ChatGPT",
      "ChatGPTActAs",
      "ChatGPTEditWithInstructions",
      "ChatGPTRun",
    },
    opts = {
      async_api_key_cmd = "lpass show --password openai_key",
    },
  },
  { "mbbill/undotree", event = "VeryLazy" },
  { "famiu/bufdelete.nvim" },
  {
    "ecthelionvi/NeoComposer.nvim",
    event = "User ExtraLazy",
    opts = {
      colors = {
        bg = "#26283f",
      },
    },
  },
  {
    "nmac427/guess-indent.nvim",
    opts = {
      auto_cmd = true,
    },
    cmd = "GuessIndent",
  },
  {
    "Dhanus3133/LeetBuddy.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    cmd = {
      "LBQuestions",
      "LBQuestion",
      "LBReset",
      "LBTest",
      "LBSubmit",
      "LBChangeLanguage",
    },
    config = true,
  },
  {
    "EtiamNullam/deferred-clipboard.nvim",
    config=true,
    event = "User ExtraLazy",
  },
  "kkharji/sqlite.lua",
  -- {
  --   "okuuva/auto-save.nvim",
  --   event = { "InsertLeave", "TextChanged" },
  --   config = function()
  --     require("auto-save").setup({
  --       execution_message = {
  --         enabled = false,
  --         message = function() end,
  --       },
  --       trigger_events = {
  --         immediate_save = { "BufLeave", "FocusLost" },
  --         defer_save = { "InsertLeave", "TextChanged" },
  --         cancel_deferred_save = { "InsertEnter" },
  --       },
  --
  --       condition = function(buf)
  --         if vim.bo[buf].buftype ~= "" then return false end
  --
  --         if vim.bo[buf].readonly then return false end
  --
  --         if
  --           #vim.diagnostic.get(
  --             buf
  --             -- { severity = vim.diagnostic.severity.ERROR }
  --           ) > 0
  --         then
  --           return false
  --         end
  --         vim.cmd.FormatDisable()
  --         return true
  --       end,
  --       write_all_buffers = false,
  --       debounce_delay = 1000,
  --     })
  --     local group = vim.api.nvim_create_augroup("autosave", { clear = true })
  --     vim.api.nvim_create_autocmd("User", {
  --       pattern = "AutoSaveWritePre",
  --       group = group,
  --       callback = function() require("lsp-format").disable({ args = "" }) end,
  --     })
  --     vim.api.nvim_create_autocmd("User", {
  --       pattern = "AutoSaveWritePost",
  --       group = group,
  --       callback = function()
  --         require("lsp-format").enable({ args = "" })
  --         local name = vim.api.nvim_buf_get_name(0)
  --         local dir = vim.fn.getcwd() .. "/"
  --         if vim.startswith(name, dir) then name = name:gsub(dir, "") end
  --
  --         vim.notify_mini(
  --           string.format("auto-saved %s", name),
  --           { title = "auto-save" }
  --         )
  --       end,
  --     })
  --   end,
  -- },
}
