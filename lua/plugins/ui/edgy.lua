return {
  {
    "folke/edgy.nvim",
    lazy = true,
    event = "VeryLazy",
    config = function()
      local function get_size()
        local round = function(n)
          if n - math.floor(n) >= 0.5 then
            return math.ceil(n)
          else
            return math.floor(n)
          end
        end
        return round(vim.o.lines / 4)
      end
      require("edgy").setup({
        left = {
          {
            ft = "SidebarNvim",
            title = "Sidebar",
          },
          {
            ft = "gh",
            title = "Gists",
          },
          {
            title = "Files",
            ft = "neo-tree",
            filter = function(buf)
              return vim.b[buf].neo_tree_source == "filesystem"
            end,
            open = "Neotree",
            size = { height = 0.5 },
          },
          {
            ft = "aerial",
            title = "Document Symbols",
            open = function() require("aerial").open() end,
          },
          { title = "Neotest Summary", ft = "neotest-summary" },
          {
            title = "Git",
            ft = "neo-tree",
            filter = function(buf)
              return vim.b[buf].neo_tree_source == "git_status"
            end,
            open = "Neotree git_status",
          },
          {
            title = "Buffers",
            ft = "neo-tree",
            filter = function(buf)
              return vim.b[buf].neo_tree_source == "buffers"
            end,
            open = "Neotree buffers",
          },
          {
            title = "Watches",
            ft = "dapui_watches",
            wo = { winbar = " Watching" },
          },
          {
            title = "Stacks",
            ft = "dapui_stacks",
            wo = { winbar = " Stacks" },
          },
          {
            title = "Breakpoints",
            ft = "dapui_breakpoints",
            wo = { winbar = " Breakpoints" },
          },
          {
            title = "Scopes",
            ft = "dapui_scopes",
            size = { height = get_size },
            wo = { winbar = " Scopes" },
          },
          "neo-tree",
        },
        bottom = {
          {
            ft = "dapui_console",
            title = "Debug Console",
            wo = { winbar = " Debug Console" },
            size = { height = get_size },
          },
          {
            ft = "dap-repl",
            title = "Debug REPL",
            wo = { winbar = false, statuscolumn = "" },
            size = { height = get_size },
          },
          {
            ft = "terminal",
            title = "Terminal",
            -- pinned = true,
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
          {
            ft = "qf",
            title = "QuickFix",
            size = { height = get_size },
          },
          {
            ft = "help",
            size = { height = 0.4 },
            -- don't open help files in edgy that we're editing
            filter = function(buf) return vim.bo[buf].buftype == "help" end,
          },
        },

        options = {
          -- left = { size = 0.25 },
          bottom = { size = get_size },
        },

        exit_when_last = true,

        animate = {
          enabled = true,
          fps = 60,
          cps = 180,
          on_begin = function() vim.g.minianimate_disable = true end,
        },
      })
    end,
  },
}
