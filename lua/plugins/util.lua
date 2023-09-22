vim.g.nvim_ghost_autostart = 0

return {
  "willothy/futures.nvim",
  "famiu/bufdelete.nvim",
  "jbyuki/venn.nvim",
  {
    "willothy/leptos.nvim",
    -- dir = "~/projects/rust/leptos-test/",
    event = "VeryLazy",
  },
  {
    "ellisonleao/glow.nvim",
    config = true,
    event = "User ExtraLazy",
  },
  {
    "rafcamlet/nvim-luapad",
    config = true,
    event = "User ExtraLazy",
  },
  {
    "lambdalisue/suda.vim",
    event = "User ExtraLazy",
  },
  {
    "mbbill/undotree",
    event = "User ExtraLazy",
  },
  {
    "willothy/NeoComposer.nvim",
    opts = {
      window = {
        border = "solid",
        winhl = {},
      },
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
    config = true,
    event = "User ExtraLazy",
  },
  {
    "EtiamNullam/deferred-clipboard.nvim",
    opts = {
      fallback = "unnamedplus",
    },
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
    "gbprod/substitute.nvim",
    opts = {
      yank_substituted_text = true,
    },
    event = "User ExtraLazy",
  },
  {
    "tamton-aquib/keys.nvim",
    config = true,
    -- cmd = "KeysToggle",
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
    -- cmd = "Attempt",
    event = "User ExtraLazy",
  },
  {
    "rawnly/gist.nvim",
    config = true,
    event = "User ExtraLazy",
    -- cmd = { "GistCreate", "GistCreateFromFile", "GistsList" },
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
    event = "User ExtraLazy",
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
  {
    "Tyler-Barham/floating-help.nvim",
    config = function()
      require("configs.editor.floating-help")
    end,
    event = "User ExtraLazy",
  },
  {
    "echasnovski/mini.misc",
    config = true,
  },
  {
    "jokajak/keyseer.nvim",
    config = true,
    event = "User ExtraLazy",
  },
  {
    "pwntester/octo.nvim",
    config = true,
    event = "User ExtraLazy",
  },
  -- {
  --   "subnut/nvim-ghost.nvim",
  --   event = "User ExtraLazy",
  -- },
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
    event = "VeryLazy",
  },
  {
    "Aasim-A/scrollEOF.nvim",
    config = true,
    event = "User ExtraLazy",
  },
}
