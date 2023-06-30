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
          pinned = true,
          open = "Neotree git_status",
        },
        {
          title = "Buffers",
          ft = "neo-tree",
          filter = function(buf) return vim.b[buf].neo_tree_source == "buffers" end,
          pinned = true,
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
            return vim.api.nvim_win_get_config(win).relative == ""
          end,
        },
        {
          ft = "Trouble",
          title = "Diagnostics",
          -- pinned = true,
          open = function() require("trouble").open() end,
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
