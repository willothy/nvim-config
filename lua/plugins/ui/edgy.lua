return {
  {
    "folke/edgy.nvim",
    event = "VeryLazy",
    -- enabled = false,
    opts = {
      bottom = {
        {
          ft = "Trouble",
          title = "Diagnostics",
          --      pinned = true,
          -- open = function()
          -- 	require("trouble").open()
          -- end,
        },
        {
          ft = "toggleterm",
          title = "Terminal",
          pinned = true,
          open = function() require("willothy.terminals").main:open() end,
          filter = function(_buf, win)
            return vim.api.nvim_win_get_config(win).relative == ""
          end,
        },
      },

      exit_when_last = true,

      animate = {
        enabled = true,
        fps = 60,
        cps = 180,
      },
    },
  },
}
