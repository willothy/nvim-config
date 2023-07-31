local anyline = false

return {
  {
    "folke/edgy.nvim",
    event = "VeryLazy",
    config = function()
      require("configs.ui.edgy")
    end,
  },
  {
    "folke/noice.nvim",
    cond = vim.g.started_by_firenvim == nil,
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    event = "UiEnter",
    config = function()
      require("configs.ui.noice")
    end,
  },
  {
    "rcarriga/nvim-notify",
    event = "UiEnter",
    config = function()
      require("configs.ui.notify")
    end,
  },
  {
    "echasnovski/mini.indentscope",
    name = "mini.indentscope",
    enabled = not anyline,
    event = "VeryLazy",
    config = function()
      require("configs.ui.mini-indentscope")
    end,
  },
  {
    "willothy/anyline.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    enabled = anyline,
    event = "VeryLazy",
    config = function()
      require("configs.ui.anyline")
    end,
  },
  {
    "nyngwang/murmur.lua",
    event = "VeryLazy",
    config = function()
      require("configs.ui.murmur")
    end,
  },
  {
    "sidebar-nvim/sidebar.nvim",
    cmd = "SidebarNvimOpen",
    opts = function()
      return require("configs.ui.sidebars").sidebar
    end,
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    cmd = "Neotree",
    opts = function()
      return require("configs.ui.sidebars").neotree
    end,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
  },
  {
    "stevearc/aerial.nvim",
    opts = function()
      return require("configs.ui.sidebars").aerial
    end,
    cmd = "AerialToggle",
  },
  {
    "nvim-tree/nvim-web-devicons",
    config = function()
      require("configs.ui.icons")
    end,
  },
  -- Color themes
  {
    "willothy/minimus",
    dependencies = {
      "rktjmp/lush.nvim",
    },
  },
  {
    "folke/tokyonight.nvim",
  },
}
