return {
  -- LAYOUT / CORE UI --
  {
    "folke/which-key.nvim",
    config = function()
      require("configs.editor.which-key")
    end,
    event = "VeryLazy",
  },
  {
    "nvim-tree/nvim-web-devicons",
    config = function()
      require("configs.ui.icons")
    end,
  },
  {
    "folke/edgy.nvim",
    -- "willothy/edgy.nvim",
    -- event = "VeryLazy",
    config = function()
      require("configs.ui.edgy")
    end,
  },
  -- {
  --   "sphamba/smear-cursor.nvim",
  --   event = "VeryLazy",
  --   opts = {
  --     legacy_computing_symbols_support = true,
  --   },
  -- },
  {
    "folke/noice.nvim",
    dependencies = { "folke/snacks.nvim" },
    event = "UiEnter",
    config = function()
      require("configs.ui.noice")
    end,
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      file_types = { "markdown", "Avante" },
    },
    ft = { "markdown", "Avante" },
  },
  -- {
  --   "3rd/image.nvim",
  --   config = function()
  --     require("image").setup({})
  --   end,
  -- },
  {
    "HakonHarnes/img-clip.nvim",
    event = "VeryLazy",
    opts = {
      default = {
        embed_image_as_base64 = false,
        prompt_for_file_name = false,
        drag_and_drop = {
          insert_mode = true,
        },
      },
    },
  },
  -- SCOPE / CURSORWORD --
  {
    "nyngwang/murmur.lua",
    event = "VeryLazy",
    config = function()
      require("configs.ui.murmur")
    end,
  },
  -- SIDEBARS --
  {
    "jackMort/tide.nvim",
    config = function()
      require("tide").setup({
        animation_duration = 150,
      })
    end,
    event = "VeryLazy",
  },
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    config = function()
      require("configs.editor.trouble")
    end,
  },
  -- WINDOWS --
  {
    "nvim-focus/focus.nvim",
    dependencies = {
      {
        "echasnovski/mini.animate",
        optional = true,
      },
    },
    config = function()
      vim.api.nvim_create_autocmd("WinEnter", {
        once = true,
        callback = function()
          require("configs.windows.focus")
        end,
      })
    end,
    event = "VeryLazy",
  },
  {
    "echasnovski/mini.animate",
    enabled = false,
    config = function()
      require("configs.windows.mini-animate")
    end,
    event = "VeryLazy",
  },
  {
    "willothy/nvim-window-picker",
    config = function()
      require("configs.windows.window-picker")
    end,
  },
  {
    "mrjones2014/smart-splits.nvim",
    config = function()
      require("configs.windows.smart-splits")
    end,
    event = "VeryLazy",
  },
  {
    "kwkarlwang/bufresize.nvim",
    config = function()
      require("configs.windows.bufresize")
    end,
  },
  {
    "stevearc/stickybuf.nvim",
    event = "VeryLazy",
    opts = {
      get_auto_pin = function(bufnr)
        -- Shell terminals will all have ft `terminal`, and can be switched between.
        -- They should be pinned by filetype only, not bufnr.
        if vim.bo[bufnr].filetype == "terminal" then
          return "filetype"
        end
        -- Non-shell terminals should be pinned by bufnr, not filetype.
        if vim.bo[bufnr].buftype == "terminal" then
          return "bufnr"
        end
        return require("stickybuf").should_auto_pin(bufnr)
      end,
    },
  },
  -- STATUS --
  {
    "willothy/nvim-cokeline",
    config = function()
      require("configs.status.cokeline")
    end,
    priority = 100,
    event = "UiEnter",
  },
  {
    "rebelot/heirline.nvim",
    config = function()
      require("configs.status.heirline")
    end,
    priority = 100,
    event = "UiEnter",
  },
  {
    "Bekaboo/dropbar.nvim",
    config = function()
      require("configs.status.dropbar")
    end,
    event = "UiEnter",
  },
  {
    "luukvbaal/statuscol.nvim",
    dependencies = {
      "lewis6991/gitsigns.nvim",
    },
    event = "UiEnter",
    config = function()
      require("configs.status.statuscol")
    end,
  },
  -- COLORS --
  {
    "willothy/nvim-colorizer.lua",
    -- dir = "~/projects/lua/nvim-colorizer.lua/",
    config = function()
      require("colorizer").setup({
        user_default_options = {
          mode = "inline",
          names = false,
          virtualtext = "■ ",
        },
      })
    end,
    cmd = "ColorizerToggle",
  },
  {
    "rktjmp/lush.nvim",
    cmd = "Lushify",
  },
}
