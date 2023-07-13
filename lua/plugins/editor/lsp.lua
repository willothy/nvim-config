local lsp_attach, lsp_setup, setup_rust, setup_null, lsp_settings
local icons = require("willothy.icons")
local lsp = function()
  local l
  if not l then l = require("willothy.lsp") end
  lsp_attach = l.lsp_attach
  lsp_setup = l.lsp_setup
  setup_rust = l.setup_rust
  setup_null = l.setup_null
  lsp_settings = l.lsp_settings
end

return {
  {
    "folke/neodev.nvim",
    lazy = true,
    ft = "lua",
    config = function()
      lsp()
      require("neodev").setup()
      require("lspconfig").lua_ls.setup({
        settings = lsp_settings["lua_ls"],
        attach = lsp_attach,
      })
    end,
  },
  {
    "aznhe21/actions-preview.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
    lazy = true,
    opts = {
      backend = { "nui", "telescope" },
      nui = {
        layout = {
          relative = "cursor",
          size = {
            width = "auto",
            height = "auto",
          },
          -- position = "auto",
          min_width = 15,
          min_height = 5,
        },
        -- options for preview area: https://github.com/MunifTanjim/nui.nvim/tree/main/lua/nui/popup
        preview = {
          size = "80%",
          border = {
            style = "rounded",
            padding = { 0, 0 },
          },
        },
        -- options for selection area: https://github.com/MunifTanjim/nui.nvim/tree/main/lua/nui/menu
        select = {
          size = "20%",
          border = {
            style = "rounded",
            padding = { 0, 0 },
          },
        },
      },
    },
  },
  {
    "j-hui/fidget.nvim",
    branch = "legacy",
    opts = {
      text = {
        spinner = "pipe", --"dots",
        done = "✓",
        commenced = "+",
        completed = "✓",
      },
      fmt = {
        stack_upwards = false,
      },
      align = {
        bottom = false,
        right = true,
      },
      window = {
        blend = 0,
        relative = "editor",
      },
    },
    lazy = true,
    config = true,
    event = "LspAttach",
  },
  {
    "smjonas/inc-rename.nvim",
    config = true,
    cmd = "IncRename",
  },
  {
    "lukas-reineke/lsp-format.nvim",
    lazy = true,
    event = "LSPAttach",
  },
  {
    -- "simrat39/rust-tools.nvim",
    "willothy/rust-tools.nvim",
    branch = "no-augment",
    config = function()
      lsp()
      setup_rust()
    end,
  },
  {
    "williamboman/mason.nvim",
    lazy = true,
    event = "VeryLazy",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "jay-babu/mason-null-ls.nvim",
    },
  },
  {
    "neovim/nvim-lspconfig",
    lazy = true,
    event = "VeryLazy",
    config = function()
      lsp()
      lsp_setup()
    end,
  },
  {
    "kevinhwang91/nvim-ufo",
    name = "ufo",
    dependencies = {
      "kevinhwang91/promise-async",
    },
    lazy = true,
  },
  {
    "jose-elias-alvarez/null-ls.nvim",
    lazy = true,
    event = "VeryLazy",
    config = function()
      lsp()
      setup_null()
    end,
  },
  {
    "ThePrimeagen/refactoring.nvim",
    lazy = true,
    event = "LspAttach",
    requires = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
  },
  {
    "kosayoda/nvim-lightbulb",
    opts = {
      ignore = {
        ft = {
          "harpoon",
          "noice",
          "neo-tree",
          "SidebarNvim",
          "Trouble",
          "terminal",
        },
        clients = { "null-ls" },
      },
      autocmd = {
        enabled = true,
        updatetime = -1,
      },
      sign = {
        enabled = true,
        priority = 100,
        hl = "DiagnosticSignWarn",
        text = icons.lsp.action_hint,
      },
    },
    lazy = true,
    event = "LspAttach",
  },
}
