return {
  -- DEVELOPMENT & TESTING --
  {
    "ThePrimeagen/refactoring.nvim",
    config = true,
    event = "LspAttach",
  },
  {
    "folke/neodev.nvim",
    config = true,
  },
  {
    "nvim-neotest/neotest",
    branch = "feat/use-external-nio",
    config = function()
      require("configs.editor.neotest")
    end,
    dependencies = {
      "rouge8/neotest-rust",
      "nvim-neotest/neotest-plenary",
    },
    event = "VeryLazy",
  },
  -- LSP UI --
  {
    "j-hui/fidget.nvim",
    config = function()
      require("configs.lsp.fidget")
    end,
    event = "LspAttach",
  },
  {
    "smjonas/inc-rename.nvim",
    config = true,
    event = "LspAttach",
  },
  -- LANGUAGE SERVERS & RELATED TOOLS --
  {
    "williamboman/mason.nvim",
    event = "VeryLazy",
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
    "sourcegraph/sg.nvim",
    config = function()
      require("configs.lsp.sourcegraph")
    end,
    cmd = {
      "CodyDo",
      "CodyTask",
      "CodyAsk",
      "CodyChat",
      "CodyToggle",
      "SourcegraphSearch",
      "SourcegraphLink",
    },
    event = "VeryLazy",
    -- build = "nvim -l build/init.lua",
  },
  {
    "garymjr/nvim-snippets",
    config = true,
    event = "InsertEnter",
    dependencies = {
      "rafamadriz/friendly-snippets",
    },
  },
  {
    "vxpm/ferris.nvim",
    config = function()
      require("ferris").setup()

      local function cmd(name, module, opts)
        vim.api.nvim_create_user_command(name, function(...)
          require(module)(...)
        end, opts or {})
      end

      cmd("FerrisExpandMacro", "ferris.methods.expand_macro")
      cmd("FerrisViewHIR", "ferris.methods.view_hir")
      cmd("FerrisViewMIR", "ferris.methods.view_mir")
      cmd("FerrisViewMemoryLayout", "ferris.methods.view_memory_layout")
      cmd("FerrisOpenCargoToml", "ferris.methods.open_cargo_toml")
      cmd("FerrisOpenParentModule", "ferris.methods.open_parent_module")
      cmd("FerrisOpenDocumentation", "ferris.methods.open_documentation")
      cmd("FerrisReloadWorkspace", "ferris.methods.reload_workspace")
    end,
    opts = {},
    cmd = {
      "FerrisViewHIR",
      "FerrisViewMIR",
      "FerrisViewMemoryLayout",
      -- "FerrisViewSyntaxTree",
      -- "FerrisViewItemTree",
      "FerrisOpenCargoToml",
      "FerrisOpenParentModule",
      "FerrisOpenDocumentation",
      "FerrisReloadWorkspace",
      -- "FerrisExpandMacro",
      -- "FerrisJoinLines",
      -- "FerrisRebuildMacros"
    },
  },
  {
    "p00f/clangd_extensions.nvim",
    config = true,
    event = "LspAttach",
  },
  -- DIAGNOSTICS & FORMATTING --
  {
    "nvimtools/none-ls.nvim",
    config = function()
      require("configs.lsp.null-ls")
    end,
    event = "VeryLazy",
  },
  {
    "stevearc/conform.nvim",
    config = function()
      require("configs.lsp.conform")
    end,
    event = "VeryLazy",
  },
  {
    "mfussenegger/nvim-lint",
    config = function()
      require("configs.lsp.nvim-lint")
    end,
    event = "DiagnosticChanged",
  },
  {
    "dgagn/diagflow.nvim",
    -- "willothy/diagflow.nvim",
    config = function()
      require("configs.lsp.diagflow")
    end,
    event = "VeryLazy",
  },
  {
    "NStefan002/speedtyper.nvim",
    cmd = "Speedtyper",
    -- dir = "~/projects/lua/speedtyper.nvim/",
    config = function()
      require("speedtyper").setup({
        window = {
          border = "solid",
        },
        vim_opt = {},
      })
    end,
  },
  -- {
  --   "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
  --   config = true,
  --   event = "DiagnosticChanged",
  -- },
  -- COMPLETION --
  {
    "hrsh7th/nvim-cmp",
    -- "willothy/nvim-cmp",
    -- dir = "~/projects/lua/nvim-cmp/",
    dependencies = {
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-nvim-lsp",
      "dmitmel/cmp-cmdline-history",
      "rcarriga/cmp-dap",
      "zbirenbaum/copilot-cmp",
      "petertriho/cmp-git",
    },
    event = { "CmdlineEnter", "InsertEnter" },
    config = function()
      require("configs.editor.cmp")
    end,
  },
  {
    "windwp/nvim-autopairs",
    config = function()
      require("configs.editor.autopairs")
    end,
    event = "InsertEnter",
  },
  {
    "windwp/nvim-ts-autotag",
    config = true,
    event = "InsertEnter",
  },
  {
    "zbirenbaum/copilot.lua",
    event = "InsertEnter",
    config = function()
      require("configs.editor.copilot")
    end,
  },
  {
    "kylechui/nvim-surround",
    config = true,
    event = "InsertEnter",
  },
  -- DEBUGGING --
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "theHamsta/nvim-dap-virtual-text",
    },
    config = function()
      require("configs.debugging.dap")
    end,
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
    },
    config = function()
      require("configs.debugging.dap-ui")
    end,
  },
  -- Individual debugger plugins
  {
    "jbyuki/one-small-step-for-vimkind",
  },
}
