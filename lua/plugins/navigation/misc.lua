return {
  {
    "chrisgrieser/nvim-spider",
    lazy = true,
  },
  {
    "toppair/reach.nvim",
    config = true,
    cmd = "ReachOpen",
    keys = {
      {
        "<leader>br",
        function() require("reach").buffers() end,
        desc = "reach buffers",
      },
      {
        "<leader>mr",
        function() require("reach").buffers() end,
        desc = "reach marks",
      },
    },
  },
}
