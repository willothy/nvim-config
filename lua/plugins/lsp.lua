return {
  -- DEVELOPMENT & TESTING --
  {
    "ThePrimeagen/refactoring.nvim",
    config = true,
    cmd = "Refactor",
  },
  {
    "willothy/lazydev.nvim",
    dependencies = {
      "Bilal2453/luvit-meta", -- type defs for vim.uv
    },
    ft = "lua",
    opts = {
      exclude = {
        "~/projects/lua",
      },
      integrations = {
        lspconfig = false,
      },
      library = {
        "luvit-meta/library",
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
      require("configs.lsp.increname")
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
      require("configs.lsp.lspconfig")
    end,
    event = "VeryLazy",
  },
  {
    "willothy/durable.nvim",
    event = "VeryLazy",
    config = true,
  },
  {
    "p00f/clangd_extensions.nvim",
    config = true,
    event = "LspAttach",
  },
  -- DIAGNOSTICS & FORMATTING --
  {
    "stevearc/conform.nvim",
    config = function()
      require("configs.formatting")
    end,
    event = "BufWritePre",
  },
  {
    "mfussenegger/nvim-lint",
    config = function()
      require("configs.linting")
    end,
    event = "VeryLazy",
  },
  {
    "dgagn/diagflow.nvim",
    config = function()
      require("configs.diagnostics")
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
    lazy = true,
    event = { "InsertEnter", "CmdlineEnter" },
    build = "cargo build --release",
    config = function()
      require("configs.completion")
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

      require("willothy.1password").read(
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
      require("configs.debugging")
    end,
  },
  -- Individual debugger plugins
  "jbyuki/one-small-step-for-vimkind",
}
