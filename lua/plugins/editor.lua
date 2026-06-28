return {
  {
    "nvim-pack/nvim-spectre",
    config = true,
    cmd = "Spectre",
  },
  {
    "nvimtools/hydra.nvim",
    dependencies = {
      "jbyuki/venn.nvim",
    },
    config = function()
      local venn_hint_utf = [[
 Arrow^^^^^^  Select region with <C-v>^^^^^^
 ^ ^ _K_ ^ ^  _f_: Surround with box ^ ^ ^ ^
 _H_ ^ ^ _L_  _<C-h>_: ◄, _<C-j>_: ▼
 ^ ^ _J_ ^ ^  _<C-k>_: ▲, _<C-l>_: ► _<C-c>_
]]

      local Hydra = require("hydra")

      -- :setlocal ve=all
      -- :setlocal ve=none
      local diagram_hydra = Hydra({
        name = "Draw Utf-8 Venn Diagram",
        hint = venn_hint_utf,
        config = {
          color = "pink",
          invoke_on_body = true,
          on_enter = function()
            vim.wo.virtualedit = "all"
          end,
        },
        mode = "n",
        body = "<leader>ve",
        heads = {
          { "<C-h>", "xi<C-v>u25c4<Esc>" }, -- mode = 'v' somehow breaks
          { "<C-j>", "xi<C-v>u25bc<Esc>" },
          { "<C-k>", "xi<C-v>u25b2<Esc>" },
          { "<C-l>", "xi<C-v>u25ba<Esc>" },
          { "H", "<C-v>h:VBox<CR>" },
          { "J", "<C-v>j:VBox<CR>" },
          { "K", "<C-v>k:VBox<CR>" },
          { "L", "<C-v>l:VBox<CR>" },
          { "f", ":VBox<CR>", { mode = "v" } },
          { "<C-c>", nil, { exit = true } },
        },
      })

      vim.api.nvim_create_user_command("Diagram", function()
        diagram_hydra:activate()
      end, {
        nargs = 0,
      })
    end,
    cmd = "Diagram",
  },
  -- COMMANDS --
  {
    "smjonas/live-command.nvim",
    config = true,
  },
  -- EDITING --
  {
    "numToStr/Comment.nvim",
    dependencies = {
      {
        "folke/ts-comments.nvim",
        config = true,
      },
    },
    opts = {
      pre_hook = function(ctx)
        -- if ctx.range.srow == ctx.range.erow then
        --   -- line
        -- else
        --   -- range
        -- end

        return require("ts-comments.comments").get(vim.bo.ft)
          or vim.bo.commentstring
      end,
      toggler = { -- Normal Mode
        line = "gcc",
        block = "gcb",
      },
      opleader = { -- Visual mode
        block = "gC",
        line = "gc",
      },
      ---@diagnostic disable-next-line: missing-fields
      extra = {
        eol = "gc$",
      },
    },
    event = "VeryLazy",
  },
  {
    "gbprod/substitute.nvim",
    opts = {
      yank_substituted_text = true,
    },
    event = "VeryLazy",
  },
  -- TREESITTER --
  {
    "nvim-treesitter/nvim-treesitter",
    -- Pinned to classic `master`: the repo was archived 2026-04-03 and its
    -- default branch is now the incompatible `main` rewrite. This keeps a
    -- stable base until the deliberate migration to the community fork.
    branch = "master",
    event = "VeryLazy",
    build = ":TSUpdate",
    -- commit = "9e1cda4e71a763ba1f1ac099498c7ce40edc6dd2",
    dependencies = {
      -- "nvim-treesitter/nvim-treesitter-textobjects",
      -- "IndianBoy42/tree-sitter-just",
      "chrisgrieser/nvim-various-textobjs",
    },
    config = function()
      require("willothy.treesitter")
    end,
  },
  {
    "jmbuhr/otter.nvim",
    ft = "markdown",
    config = function()
      require("configs.editor.otter")
    end,
  },
  {
    "folke/todo-comments.nvim",
    config = true,
    event = "VeryLazy",
  },
  -- DEFAULT FEATURE EXTENSIONS --
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    config = function()
      require("configs.editor.snacks")
    end,
  },
  {
    "gbprod/yanky.nvim",
    -- enabled = false,
    dependencies = {
      "kkharji/sqlite.lua",
    },
    event = "VeryLazy",
    opts = {
      ring = { storage = "sqlite" },
      system_clipboard = {
        sync_with_ring = false,
      },
    },
  },
  {
    "utilyre/sentiment.nvim",
    event = "VeryLazy",
    config = true,
  },
  -- FILE MANAGEMENT --
  {
    "stevearc/oil.nvim",
    config = function()
      require("configs.editor.oil")
    end,
    cmd = "Oil",
  },
  {
    "echasnovski/mini.visits",
    config = true,
    event = "VeryLazy",
  },
  -- SESSIONS / PROJECTS --
  {
    "stevearc/resession.nvim",
    dependencies = {
      {
        "tiagovla/scope.nvim",
        config = true,
        event = "VeryLazy",
      },
      "stevearc/oil.nvim",
    },
    config = function()
      require("willothy.sessions")
    end,
    event = "UiEnter",
  },
  -- {
  --   -- "ahmedkhalf/project.nvim",
  --   "DrKJeff16/project.nvim",
  --   name = "project_nvim",
  --   event = "VeryLazy",
  --   opts = {
  --     detection_methods = {
  --       "lsp",
  --       "pattern",
  --     },
  --     patterns = {
  --       ".git",
  --       "package.json",
  --       "Cargo.toml",
  --       "Makefile",
  --     },
  --     exclude_dirs = {
  --       "~/.local/",
  --       "~/.cargo/",
  --     },
  --     ignore_lsp = { "savior", "copilot" },
  --     silent_chdir = true,
  --     show_hidden = true,
  --     scope_chdir = "tab",
  --   },
  -- },
  {
    "willothy/savior.nvim",
    config = true,
    event = { "InsertEnter", "TextChanged" },
  },
  -- TERMINAL --
  {
    "akinsho/toggleterm.nvim",
    cmd = "ToggleTerm",
    -- dir = "~/projects/lua/toggleterm.nvim/",
    config = function()
      require("configs.terminal.toggleterm")
    end,
  },
  {
    "willothy/flatten.nvim",
    -- dir = "~/projects/lua/flatten.nvim/",
    lazy = false,
    priority = 1000,
    config = function()
      require("configs.terminal.flatten")
    end,
  },
  {
    "willothy/wezterm.nvim",
    -- dir = "~/projects/lua/wezterm.nvim/",
    config = function()
      require("configs.editor.wezterm")
    end,
    cmd = { "Wezterm" },
  },
  {
    "stevearc/overseer.nvim",
    config = function()
      require("willothy.tasks")
    end,
    event = { "UiEnter", "VeryLazy" },
  },
  -- NAVIGATION --
  {
    "folke/flash.nvim",
    config = function()
      require("configs.navigation.flash")
    end,
    keys = {
      { "f", desc = "flash" },
      { "F", desc = "flash" },
      { "t", desc = "flash" },
      { "T", desc = "flash" },
    },
  },
  {
    "chrisgrieser/nvim-spider",
    config = true,
  },
  {
    "abecodes/tabout.nvim",
  },
  -- GIT --
  {
    "lewis6991/gitsigns.nvim",
    -- enabled = false,
    config = function()
      require("configs.git.gitsigns")
    end,
    event = "VeryLazy",
  },
  {
    "sindrets/diffview.nvim",
    config = true,
    cmd = {
      "DiffviewOpen",
      "DiffviewToggleFiles",
      "DiffviewFocusFiles",
      "DiffviewRefresh",
      "DiffviewFileHistory",
    },
  },
  {
    "akinsho/git-conflict.nvim",
    config = function()
      require("configs.git.git-conflict")
    end,
    event = "VeryLazy",
  },
  {
    "NeogitOrg/neogit",
    cmd = "Neogit",
    config = function()
      require("configs.git.neogit")
    end,
  },
  -- MISC --
  {
    "echasnovski/mini.trailspace",
    config = function()
      require("mini.trailspace").setup()
    end,
    event = { "VimEnter" },
  },
  {
    "chomosuke/term-edit.nvim",
    opts = {
      prompt_end = "-> ",
    },
    event = "TermEnter",
  },
  {
    "tris203/precognition.nvim",
    opts = {
      startVisible = false,
      showBlankVirtLine = false,
    },
    event = "VeryLazy",
  },
  {
    "johmsalas/text-case.nvim",
    opts = {
      default_keymappings_enabled = false,
    },
  },
}
