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
  {
    "nmac427/guess-indent.nvim",
    opts = { auto_cmd = true },
    event = "VeryLazy",
  },
  {
    "kawre/leetcode.nvim",
    opts = {
      lang = "rust",
      plugins = {
        non_standalone = true,
      },
    },
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
    event = "BufRead Cargo.toml",
  },
  -- -- Like crates.nvim but for package.json, but seems to be not as good yet
  -- {
  --   "vuki656/package-info.nvim",
  --   event = "BufRead package.json",
  --   opts = {
  --     -- fallback to pnpm if auto-detection doesn't work
  --     notifications = false,
  --     package_manager = "pnpm",
  --   },
  -- },
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
