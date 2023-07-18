return {
  {
    "folke/edgy.nvim",
    lazy = true,
    event = "VeryLazy",
    opts = {
      left = {
        {
          ft = "SidebarNvim",
          title = "Sidebar",
        },
        {
          title = "Files",
          ft = "neo-tree",
          filter = function(buf)
            return vim.b[buf].neo_tree_source == "filesystem"
          end,
          pinned = true,
          open = "Neotree",
          size = { height = 0.5 },
        },
        {
          ft = "aerial",
          title = "Document Symbols",
          pinned = true,
          open = function() require("aerial").open() end,
        },
        { title = "Neotest Summary", ft = "neotest-summary" },
        {
          title = "Git",
          ft = "neo-tree",
          filter = function(buf)
            return vim.b[buf].neo_tree_source == "git_status"
          end,
          -- pinned = true,
          open = "Neotree git_status",
        },
        {
          title = "Buffers",
          ft = "neo-tree",
          filter = function(buf) return vim.b[buf].neo_tree_source == "buffers" end,
          -- pinned = true,
          open = "Neotree buffers",
        },
        "neo-tree",
      },
      bottom = {
        {
          ft = "terminal",
          title = "Terminal",
          pinned = true,
          open = function() require("willothy.terminals").main:open() end,
          filter = function(_buf, win)
            return not vim.api.nvim_win_get_config(win).zindex
          end,
        },
        {
          ft = "Trouble",
          title = "Diagnostics",
          open = function() require("trouble").open() end,
        },
        {
          ft = "noice",
          filter = function(_buf, win)
            return not vim.api.nvim_win_get_config(win).zindex
          end,
          size = { height = 0.4 },
        },
        { ft = "qf", title = "QuickFix" },
        {
          ft = "help",
          size = { height = 0.4 },
          -- don't open help files in edgy that we're editing
          filter = function(buf) return vim.bo[buf].buftype == "help" end,
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
