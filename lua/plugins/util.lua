vim.g.nvim_ghost_autostart = 0

return {
  "willothy/futures.nvim",
  "notomo/importgraph.nvim",
  {
    "ellisonleao/glow.nvim",
    config = true,
    event = "CmdlineEnter",
  },
  {
    "rafcamlet/nvim-luapad",
    event = "CmdlineEnter",
    config = true,
  },
  {
    "Aasim-A/scrollEOF.nvim",
    opts = {
      disabled_filetypes = { "terminal" },
      disabled_modes = { "t" },
    },
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
    "AckslD/nvim-neoclip.lua",
    opts = {
      enable_persistent_history = true,
      continuous_sync = true,
    },
    event = "User ExtraLazy",
  },
  {
    "nacro90/numb.nvim",
    config = true,
    event = "User ExtraLazy",
  },
  {
    "jbyuki/venn.nvim",
    event = "CmdlineEnter",
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
    event = "CmdlineEnter",
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
      require("configs.editor.crates")
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
    event = "CmdlineEnter",
  },
  {
    "pwntester/octo.nvim",
    config = true,
    event = "CmdlineEnter",
  },
  {
    "subnut/nvim-ghost.nvim",
    event = "User ExtraLazy",
  },
  {
    "utilyre/sentiment.nvim",
    event = "VeryLazy",
    opts = {
      delay = 30,
      pairs = {
        { "(", ")" },
        { "{", "}" },
        { "[", "]" },
      },
    },
  },
  {
    "mong8se/actually.nvim",
    config = true,
    event = "User ExtraLazy",
  },
  {
    "gbprod/stay-in-place.nvim",
    config = true,
    event = "User ExtraLazy",
  },
}
