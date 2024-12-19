vim.g.nvim_ghost_autostart = 0

return {
  {
    "jbyuki/venn.nvim",
    cmd = "VBox",
  },
  {
    "rafcamlet/nvim-luapad",
    config = true,
    cmd = "Luapad",
  },
  {
    -- TODO: Look for Lua-based and automatic alternative
    "lambdalisue/suda.vim",
    cmd = { "SudaRead", "SudaWrite" },
  },
  {
    "mbbill/undotree",
    cmd = { "UndotreeToggle", "UndotreeShow" },
  },
  -- {
  --   -- FIXME: This doesn't really work
  --   "ecthelionvi/NeoComposer.nvim",
  --   dependencies = { "kkharji/sqlite.lua" },
  --   config = function()
  --     require("configs.editor.neocomposer")
  --   end,
  -- },
  {
    "nmac427/guess-indent.nvim",
    opts = { auto_cmd = true },
    event = "VeryLazy",
  },
  {
    "kawre/leetcode.nvim",
    config = function()
      require("configs.editor.leetcode")
    end,
    cmd = "Leet",
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
    "tzachar/highlight-undo.nvim",
    config = true,
    event = "VeryLazy",
  },
  {
    "nvchad/minty",
    lazy = true,
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
    "jokajak/keyseer.nvim",
    config = true,
    cmd = "KeySeer",
  },
  {
    "pwntester/octo.nvim",
    config = true,
    cmd = "Octo",
  },
  {
    "gbprod/stay-in-place.nvim",
    config = true,
    event = "VeryLazy",
  },
}
