vim.g.nvim_ghost_autostart = 0

return {
  "famiu/bufdelete.nvim",
  "jbyuki/venn.nvim",
  "willothy/micro-async.nvim",
  {
    "willothy/leptos.nvim",
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
    "ecthelionvi/NeoComposer.nvim",
    event = "User ExtraLazy",
    config = function()
      require("configs.editor.neocomposer")
    end,
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
    "AckslD/nvim-neoclip.lua",
    opts = {
      enable_persistent_history = true,
      continuous_sync = true,
    },
    event = "User ExtraLazy",
  },
  {
    "tamton-aquib/keys.nvim",
    config = true,
    -- cmd = "KeysToggle",
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
    event = "CmdlineEnter",
    config = function()
      require("configs.editor.hypersonic")
    end,
  },
  {
    "tzachar/highlight-undo.nvim",
    config = true,
    event = "User ExtraLazy",
  },
  {
    "ziontee113/color-picker.nvim",
    config = true,
    cmd = "PickColor",
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
    cmd = "FloatingHelp",
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
  -- TODO: re-enable this
  -- {
  --   "subnut/nvim-ghost.nvim",
  --   event = "User ExtraLazy",
  -- },
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
