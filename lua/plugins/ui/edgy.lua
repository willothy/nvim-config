return {
  {
    "willothy/edgy.nvim",
    branch = "close-when-hidden",
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
          ft = "terminal",
          title = "Terminal",
          pinned = true,
          open = function() require("willothy.terminals").main:open() end,
          filter = function(_buf, win)
            return vim.api.nvim_win_get_config(win).relative == ""
          end,
        },
      },

      exit_when_last = true,
      close_when_all_hidden = true,

      animate = {
        enabled = true,
        fps = 60,
        cps = 180,
      },
    },
  },
}
