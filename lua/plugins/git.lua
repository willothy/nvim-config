return {
  {
    "lewis6991/gitsigns.nvim",
    event = "User ExtraLazy",
    config = function()
      require("configs.git.gitsigns")
    end,
  },
  {
    "sindrets/diffview.nvim",
    config = true,
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
  },
  {
    "akinsho/git-conflict.nvim",
    event = "User ExtraLazy",
    config = function()
      require("configs.git.git-conflict")
    end,
  },
  {
    "NeogitOrg/neogit",
    dependencies = "nvim-lua/plenary.nvim",
    event = "User ExtraLazy",
    config = function()
      require("configs.git.neogit")
    end,
  },
  {
    "linrongbin16/gitlinker.nvim",
    event = "User ExtraLazy",
    config = function()
      require("configs.git.gitlinker")
    end,
  },
}
