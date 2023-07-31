return {
  {
    "folke/flash.nvim",
    lazy = true,
    event = "VeryLazy",
    config = function()
      require("configs.navigation.flash")
    end,
  },
  {
    "ThePrimeagen/harpoon",
    config = true,
    event = "User ExtraLazy",
  },
  {
    "cbochs/portal.nvim",
    config = function()
      require("configs.navigation.portal")
    end,
  },
  {
    "chrisgrieser/nvim-spider",
    lazy = true,
  },
  {
    "toppair/reach.nvim",
    config = true,
    cmd = "ReachOpen",
  },
}
