return {
  {
    "willothy/edgy.nvim",
    branch = "close-when-hidden",
    event = "VeryLazy",
    opts = {
      left = {
        {
          ft = "SidebarNvim",
          title = "Sidebar",
        },
        {
          title = "Neo-Tree",
          ft = "neo-tree",
          filter = function(buf)
            return vim.b[buf].neo_tree_source == "filesystem"
          end,
          pinned = true,
          open = function() vim.api.nvim_input("<esc><space>e") end,
          size = { height = 0.5 },
        },
        { title = "Neotest Summary", ft = "neotest-summary" },
        {
          title = "Neo-Tree Git",
          ft = "neo-tree",
          filter = function(buf)
            return vim.b[buf].neo_tree_source == "git_status"
          end,
          pinned = true,
          open = "Neotree position=right git_status",
        },
        {
          title = "Neo-Tree Buffers",
          ft = "neo-tree",
          filter = function(buf) return vim.b[buf].neo_tree_source == "buffers" end,
          pinned = true,
          open = "Neotree position=top buffers",
        },
        "neo-tree",
      },
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
        {
          ft = "noice",
          size = { height = 0.4 },
          filter = function(_buf, win)
            return vim.api.nvim_win_get_config(win).relative == ""
          end,
        },
        { ft = "qf", title = "QuickFix" },
        {
          ft = "help",
          size = { height = 20 },
          -- don't open help files in edgy that we're editing
          filter = function(buf) return vim.bo[buf].buftype == "help" end,
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
