vim.g.nvim_ghost_autostart = 0

return {
  "willothy/futures.nvim",
  "famiu/bufdelete.nvim",
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
    event = "User ExtraLazy",
    cmd = { "SudaWrite", "SudaRead" },
  },
  {
    "mbbill/undotree",
    cmd = { "UndotreeFocus", "UndotreeShow", "UndotreeToggle", "UndotreeHide" },
  },
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
    config = true,
    cmd = {
      "LBCheckCookies",
      "LBClose",
      "LBSubmit",
      "LBTest",
      "LBSplit",
      "LBReset",
      "LBQuestion",
      "LBQuestions",
      "LBChangeLanguage",
    },
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
    event = "CmdlineEnter",
  },
  {
    "jbyuki/venn.nvim",
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
    cmd = { "PickColor", "PickColorInsert" },
  },
  {
    "krady21/compiler-explorer.nvim",
    config = true,
    cmd = {
      "CEAddLibrary",
      "CECompile",
      "CECompileLive",
      "CEDeleteCache",
      "CEFormat",
      "CELoadExample",
      "CEOpenWebsite",
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
    "echasnovski/mini.misc",
    config = true,
  },
  {
    "jokajak/keyseer.nvim",
    config = true,
    cmd = "Keyseer",
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
}
