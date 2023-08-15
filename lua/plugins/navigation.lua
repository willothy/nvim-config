local spider = function(motion)
  return {
    motion,
    function()
      require("spider").motion(motion)
    end,
    desc = "which_key_ignore",
    mode = { "n", "o", "x" },
  }
end
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
    keys = {
      spider("w"),
      spider("b"),
      spider("e"),
      spider("ge"),
    },
  },
  {
    "toppair/reach.nvim",
    config = true,
    cmd = "ReachOpen",
  },
  {
    "rhysd/accelerated-jk",
    event = "User ExtraLazy",
  },
}
