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
    event = "User ExtraLazy",
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
      filetype_exclude = {
        "TelescopePrompt",
      },
    },
    event = "User ExtraLazy",
  },
  {
    "Dhanus3133/LeetBuddy.nvim",
    event = "User ExtraLazy",
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
    cmd = "VBox",
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
    config = true,
    event = "User ExtraLazy",
  },
  {
    "m-demare/attempt.nvim",
    config = function()
      require("configs.editor.attempt")
    end,
    event = "User ExtraLazy",
  },
  {
    "rawnly/gist.nvim",
    config = true,
    event = "User ExtraLazy",
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
    config = true,
  },
  {
    "tzachar/highlight-undo.nvim",
    config = true,
    event = "User ExtraLazy",
  },
  {
    "ziontee113/color-picker.nvim",
    config = true,
    event = "User ExtraLazy",
  },
  {
    "krady21/compiler-explorer.nvim",
    config = true,
    event = "User ExtraLazy",
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
    "pwntester/octo.nvim",
    config = true,
    cmd = "Octo",
  },
  -- {
  --   "subnut/nvim-ghost.nvim",
  --   event = "User ExtraLazy",
  -- },
}
