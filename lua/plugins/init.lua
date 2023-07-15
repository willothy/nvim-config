return {
  { import = "plugins.core" },
  { import = "plugins.ui" },
  { import = "plugins.git" },
  { import = "plugins.editor" },
  { import = "plugins.navigation" },
  { import = "plugins.status" },
  { import = "plugins.terminal" },
  { import = "plugins.util" },

  -- no-config plugins
  { "mbbill/undotree", event = "VeryLazy" },
  "famiu/bufdelete.nvim",
  "kkharji/sqlite.lua",
  "AckslD/nvim-neoclip.lua",
  {
    "ecthelionvi/NeoComposer.nvim",
    config = true,
  },
}
