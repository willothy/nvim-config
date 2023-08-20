return {
  {
    "ellisonleao/glow.nvim",
    config = true,
    cmd = "Glow",
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
    },
    cmd = {
      "ChatGPT",
      "ChatGPTActAs",
      "ChatGPTEditWithInstructions",
      "ChatGPTRun",
    },
    opts = {
      api_key_cmd = "lpass show --password openai_key",
    },
  },
  { "mbbill/undotree", event = "User ExtraLazy" },
  { "famiu/bufdelete.nvim" },
  {
    "willothy/NeoComposer.nvim",
    requires = { "kkharji/sqlite.lua" },
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
    event = "User ExtraLazy",
  },
  {
    "Dhanus3133/LeetBuddy.nvim",
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
    config = true,
    event = "User ExtraLazy",
  },
  {
    "kkharji/sqlite.lua",
  },
  {
    "nacro90/numb.nvim",
    config = true,
    event = "User ExtraLazy",
  },
  {
    "willothy/futures.nvim",
  },
  {
    "jbyuki/venn.nvim",
    cmd = { "VBox" },
  },
  {
    "gbprod/substitute.nvim",
    opts = {
      yank_substituted_text = true,
    },
    event = "User ExtraLazy",
  },
  {
    "tamton-aquib/keys.nvim",
    config = true,
    cmd = "KeysToggle",
  },
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = true,
    event = "User ExtraLazy",
  },
  {
    "m-demare/attempt.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("configs.editor.attempt")
    end,
    cmd = "Attempt",
  },
  {
    "rawnly/gist.nvim",
    cmd = { "GistCreate", "GistCreateFromFile", "GistsList" },
    config = true,
  },
  {
    "Saecki/crates.nvim",
    config = function()
      require("crates").setup({
        null_ls = {
          enabled = true,
          name = "crates.nvim",
        },
      })
      require("cmp").setup.buffer({ sources = { { name = "crates" } } })
    end,
    event = "BufRead Cargo.toml",
  },
  {
    "tomiis4/Hypersonic.nvim",
    event = "CmdlineEnter",
    cmd = "Hypersonic",
    config = true,
  },
  {
    "creativenull/dotfyle-metadata.nvim",
    cmd = { "DotfyleGenerate", "DotfyleOpen" },
  },
  {
    "tzachar/highlight-undo.nvim",
    config = true,
    event = "User ExtraLazy",
  },
  {
    "stevearc/oil.nvim",
    opts = {
      default_file_explorer = false,
    },
    cmd = "Oil",
  },
  {
    "ziontee113/color-picker.nvim",
    config = true,
    cmd = {
      "PickColor",
      "PickColorInsert",
    },
  },
  {
    "krady21/compiler-explorer.nvim",
    config = true,
    cmd = {
      "CECompile",
      "CECompileLive",
      "CEFormat",
      "CEAddLibrary",
      "CELoadExample",
      "CEOpenWebsite",
      "CEDeleteCache",
      "CEShowTooltip",
      "CEGotoLabel",
    },
  },
  -- {
  --   "willothy/piemenu.nvim",
  --   enabled = false,
  --   config = function()
  --     require("configs.editor.piemenu")
  --   end,
  --   keys = {
  --     {
  --       "<RightMouse>",
  --       function()
  --         local mouse = vim.fn.getmousepos()
  --         local win = vim.api.nvim_get_current_win()
  --         local view = vim.fn.winsaveview()
  --
  --         require("piemenu").start("main", {
  --           position = {
  --             mouse.screenrow,
  --             mouse.screencol,
  --           },
  --         })
  --         vim.api.nvim_win_call(win, function()
  --           vim.fn.winrestview(view)
  --         end)
  --       end,
  --       mode = { "n", "v" },
  --     },
  --   },
  -- },
  {
    "Tyler-Barham/floating-help.nvim",
    config = function()
      require("configs.editor.floating-help")
    end,
    event = "CmdlineEnter",
  },
  {
    "echasnovski/mini.misc",
    config = true,
  },
  {
    "jokajak/keyseer.nvim",
    config = true,
    cmd = "KeySeer",
  },
  {
    "echasnovski/mini.colors",
    config = true,
    cmd = "Colorscheme",
  },
  {
    "pwntester/octo.nvim",
    config = true,
    cmd = "Octo",
  },
}
