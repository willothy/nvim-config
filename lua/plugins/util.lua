vim.g.nvim_ghost_autostart = 0

return {
  "famiu/bufdelete.nvim",
  { "jbyuki/venn.nvim", cmd = "VBox" },
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
    "FredeEB/tardis.nvim",
    config = true,
    cmd = "Tardis",
  },
  {
    -- "ecthelionvi/NeoComposer.nvim",
    "willothy/NeoComposer.nvim",
    branch = "fix-store",
    -- dir = "~/projects/lua/NeoComposer.nvim",
    -- dependencies = {
    --   "kkharji/sqlite.lua",
    -- },
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
    -- "kawre/leetcode.nvim",
    "willothy/leetcode.nvim",
    branch = "feat-start-with-cmd",
    -- dir = "~/projects/lua/leetcode.nvim",
    opts = {
      lang = "rust",
      plugins = {
        nonstandalone = true,
      },
    },
    cmd = "Leet",
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
    "neph-iap/easycolor.nvim",
    opts = { ui = { border = "solid" } },
    cmd = "EasyColor",
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
    "chrisgrieser/nvim-scissors",
    opts = {
      editSnippetPopup = {
        border = "solid",
      },
      jsonFormatter = "jq",
    },
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
