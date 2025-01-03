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
    opts = {
      exclude = {
        "~/projects/lua",
      },
      integrations = {
        lspconfig = true,
      },
      library = {
        "luvit-meta/library",
        vim.env.VIMRUNTIME,
      },
    },
  },
  {
    "nvim-neotest/neotest",
    config = function()
      require("configs.editor.neotest")
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
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
    },
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      require("willothy.lsp")
    end,
    event = "VeryLazy",
  },
  {
    "willothy/durable.nvim",
    event = "VeryLazy",
    config = true,
  },
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
  -- COMPLETION --
  {
    "Saghen/blink.cmp",
    dependencies = {
      "Saghen/blink.compat",

      "rafamadriz/friendly-snippets",
      "giuxtaposition/blink-cmp-copilot",
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
      disable_filetype = { "TelescopePrompt" },
    },
    event = "InsertEnter",
  },
  -- AI
  {
    "yetone/avante.nvim",
    event = "CmdlineEnter",
    build = "make",
    config = function()
      local function setup(key)
        vim.env["ANTHROPIC_API_KEY"] = key
        ---@diagnostic disable-next-line: missing-fields
        require("avante").setup({
          provider = "claude",
          claude = {},
          behavior = {},
        })
        vim.cmd("highlight default link AvanteSuggestion PmenuSel")
      end

      local key = require("durable").kv.get("anthropic-api-key")
      if key ~= nil then
        setup(key)
        return
      end

      require("willothy.lib.1password").read(
        "op://Personal/Anthropic API Key/credential",
        vim.schedule_wrap(function(res)
          res = vim.trim(res)
          setup(res)
          require("durable").kv.set("anthropic-api-key", res)
        end)
      )
    end,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
      "zbirenbaum/copilot.lua",

      -- support for image pasting
      "HakonHarnes/img-clip.nvim",
      "MeanderingProgrammer/render-markdown.nvim",
    },
  },
  {
    "zbirenbaum/copilot.lua",
    opts = {
      suggestion = {
        auto_trigger = false,
        hide_during_completion = true,
      },
    },
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
