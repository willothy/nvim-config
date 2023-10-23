vim.g.nvim_ghost_autostart = 0

return {
  "famiu/bufdelete.nvim",
  "jbyuki/venn.nvim",
  {
    "willothy/micro-async.nvim",
    -- dir = "~/projects/lua/micro-async.nvim",
  },
  -- {
  --   "willothy/nvim-rterm",
  --   dir = "~/projects/rust/nvim-rterm/",
  --   event = "VeryLazy",
  -- },
  {
    "willothy/leptos.nvim",
    event = "VeryLazy",
  },
  {
    "ellisonleao/glow.nvim",
    config = true,
    cmd = "Glow",
  },
  {
    "rafcamlet/nvim-luapad",
    config = true,
    cmd = "Luapad",
  },
  {
    "lambdalisue/suda.vim",
    cmd = { "SudaRead", "SudaWrite" },
  },
  {
    "mbbill/undotree",
    cmd = { "UndotreeToggle", "UndotreeShow" },
  },
  {
    "ecthelionvi/NeoComposer.nvim",
    event = "VeryLazy",
    config = function()
      require("configs.editor.neocomposer")
    end,
  },
  {
    "nmac427/guess-indent.nvim",
    opts = { auto_cmd = true },
    event = "VeryLazy",
  },
  {
    "Dhanus3133/LeetBuddy.nvim",
    config = true,
    cmd = {
      "LBQuestion",
      "LBQuestions",
      "LBSplit",
    },
  },
  {
    "AckslD/nvim-neoclip.lua",
    opts = {
      enable_persistent_history = true,
      continuous_sync = true,
    },
    event = "VeryLazy",
  },
  {
    "m-demare/attempt.nvim",
    config = function()
      require("configs.editor.attempt")
    end,
    cmd = "Attempt",
  },
  {
    "rawnly/gist.nvim",
    config = true,
    cmd = { "GistCreate", "GistCreateFromFile", "GistsList" },
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
    cmd = "Hypersonic",
    config = function()
      require("configs.editor.hypersonic")
    end,
  },
  {
    "tzachar/highlight-undo.nvim",
    config = true,
    event = "VeryLazy",
  },
  {
    "ziontee113/color-picker.nvim",
    config = true,
    cmd = "PickColor",
  },
  {
    "krady21/compiler-explorer.nvim",
    config = true,
    cmd = {
      "CECompile",
      "CECompileLive",
    },
  },
  {
    "Tyler-Barham/floating-help.nvim",
    config = function()
      require("configs.editor.floating-help")
    end,
    cmd = "FloatingHelp",
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
  -- TODO: re-enable this
  -- {
  --   "subnut/nvim-ghost.nvim",
  --   event = "VeryLazy",
  -- },
  {
    "mong8se/actually.nvim",
    config = true,
    event = "VeryLazy",
  },
  {
    "gbprod/stay-in-place.nvim",
    config = true,
    event = "VeryLazy",
  },
}
