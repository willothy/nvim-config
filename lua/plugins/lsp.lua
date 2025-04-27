return {
  -- DEVELOPMENT & TESTING --
  {
    "ThePrimeagen/refactoring.nvim",
    config = true,
    cmd = "Refactor",
  },
  {
    -- "willothy/lazydev.nvim",
    "folke/lazydev.nvim",
    -- enabled = false,
    dependencies = {
      "Bilal2453/luvit-meta", -- type defs for vim.uv
    },
    ft = "lua",
    config = function()
      require("lazydev").setup({
        -- exclude = {
        --   "~/projects/lua",
        -- },
        integrations = {
          lspconfig = true,
        },
        library = {
          "luvit-meta/library",
          vim.env.VIMRUNTIME,
          -- "~/projects/lua/lua-orm/",
          -- unpack(vim.api.nvim_get_runtime_file("lua/*", true)),
        },
      })
    end,
  },
  {
    "nvim-neotest/neotest",
    config = function()
      require("willothy.testing")
    end,
    dependencies = {
      "rouge8/neotest-rust",
    },
    cmd = "Neotest",
  },
  -- LSP UI --
  {
    "j-hui/fidget.nvim",
    opts = {
      progress = {
        display = {
          overrides = {
            rust_analyzer = { name = "rust-analyzer" },
            lua_ls = { name = "lua-ls" },
          },
        },
      },
    },
    event = "LspAttach",
  },
  {
    "smjonas/inc-rename.nvim",
    config = function()
      require("inc_rename").setup({
        show_message = false,
        post_hook = function(opts)
          local nrenames, nfiles = unpack(vim
            .iter(opts)
            :map(function(_, renames)
              return vim.tbl_count(renames)
            end)
            :fold({ 0, 0 }, function(acc, val)
              acc[1] = acc[1] + val
              acc[2] = acc[2] + 1
              return acc
            end))
          vim.notify(
            string.format(
              "%d instance%s in %d files",
              nrenames,
              nrenames == 1 and "" or "s",
              nfiles
            ),
            vim.log.levels.INFO,
            {
              title = "RENAMED",
            }
          )
        end,
      })
    end,
    cmd = "IncRename",
  },
  -- LANGUAGE SERVERS & RELATED TOOLS --
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    config = true,
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      require("willothy.lsp")
    end,
    event = "VeryLazy",
  },
  -- {
  --   "Zeioth/garbage-day.nvim",
  --   config = true,
  --   event = "LspAttach",
  -- },
  -- {
  --   "p00f/clangd_extensions.nvim",
  --   config = true,
  --   event = "LspAttach",
  -- },
  -- DIAGNOSTICS & FORMATTING --
  {
    "stevearc/conform.nvim",
    config = function()
      require("willothy.formatting")
    end,
    event = "BufWritePre",
  },
  {
    "mfussenegger/nvim-lint",
    config = function()
      require("willothy.linting")
    end,
    event = "VeryLazy",
  },
  {
    "dgagn/diagflow.nvim",
    config = function()
      require("willothy.diagnostics")
    end,
    event = "DiagnosticChanged",
  },
  {
    "boltlessengineer/sense.nvim",
    init = function()
      vim.g.sense_nvim = {
        -- show hint in statuscolumn, but not in the window itself
        presets = {
          virtualtext = {
            enabled = false,
          },
          statuscolumn = {
            enabled = true,
          },
        },
      }
    end,
    event = "DiagnosticChanged",
  },
  -- COMPLETION --
  {
    "Saghen/blink.cmp",
    dependencies = {
      "Saghen/blink.compat",
      -- "giuxtaposition/blink-cmp-copilot",
      "fang2hou/blink-copilot",
      "copilotlsp-nvim/copilot-lsp",

      -- "Kaiser-Yang/blink-cmp-avante",

      -- "rafamadriz/friendly-snippets",
      "Saecki/crates.nvim",
      "windwp/nvim-ts-autotag",
    },
    event = { "InsertEnter", "CmdlineEnter" },
    build = "cargo build --release",
    config = function()
      require("willothy.completion")
    end,
  },
  {
    "windwp/nvim-autopairs",
    opts = {
      disable_filetype = { "snacks_picker_input" },
    },
    event = "InsertEnter",
  },
  -- AI
  {
    "copilotlsp-nvim/copilot-lsp",
    dependencies = {
      "fang2hou/blink-copilot",
    },
    -- dir = "~/projects/lua/copilot-lsp",
    init = function()
      vim.g.copilot_nes_debounce = 250
      vim.lsp.enable("copilot_ls")
    end,
  },
  {
    "kylechui/nvim-surround",
    config = true,
    event = "VeryLazy",
  },
  -- DEBUGGING --
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "theHamsta/nvim-dap-virtual-text",
    },
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
    },
    config = function()
      require("willothy.debugging")
    end,
  },
  -- Individual debugger plugins
  "jbyuki/one-small-step-for-vimkind",
}
