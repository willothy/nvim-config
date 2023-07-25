return {
  {
    "sindrets/diffview.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
  },
  {
    "akinsho/git-conflict.nvim",
    opts = {
      default_mappings = true, -- disable buffer local mapping created by this plugin
      default_commands = true, -- disable commands created by this plugin
      disable_diagnostics = false, -- This will disable the diagnostics in a buffer whilst it is conflicted
      highlights = {
        incoming = "DiffAdd",
        current = "DiffText",
      },
    },
    event = "User ExtraLazy",
  },
  {
    "NeogitOrg/neogit",
    dependencies = "nvim-lua/plenary.nvim",
    config = true,
  },
}
