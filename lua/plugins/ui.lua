return {
  -- LAYOUT / CORE UI --
  {
    "folke/which-key.nvim",
    opts = {
      delay = 50,
      preset = "helix",
      win = {
        border = "single",
        wo = {
          winhl = "FloatTitle:NormalFloat",
        },
      },
    },
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
  {
    "sphamba/smear-cursor.nvim",
    enabled = false,
    event = "VeryLazy",
    opts = {
      -- legacy_computing_symbols_support = true,
    },
  },
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
    config = function()
      require("render-markdown").setup({
        file_types = { "markdown", "Avante", "snacks_notif" },
        on = {
          attach = vim.schedule_wrap(function()
            require("render-markdown").enable()
          end),
        },
      })
    end,
    ft = { "markdown", "Avante", "snacks_notif" },
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
    -- "willothy/nvim-cokeline",
    "plax-00/nvim-cokeline",
    branch = "pick-close-multiple",
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
    dependencies = {
      "nvim-telescope/telescope-fzf-native.nvim",
    },
    -- version = "10",
    config = function()
      require("configs.status.dropbar")
    end,
    -- config = true,
    event = "UiEnter",
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
    init = function()
      vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        callback = function()
          require("snacks").toggle
            .new({
              name = "Colorizer",
              get = function()
                return require("colorizer").is_buffer_attached(0) ~= nil
              end,
              set = function(enabled)
                if enabled then
                  require("colorizer").attach_to_buffer(0)
                else
                  require("colorizer").detach_from_buffer(0)
                end
              end,
            })
            :map("<leader>uc")
        end,
      })
    end,
    cmd = "ColorizerToggle",
  },
  {
    "rktjmp/lush.nvim",
    cmd = "Lushify",
  },
}
