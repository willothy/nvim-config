return {
  "famiu/bufdelete.nvim",
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "make",
  },
  {
    "https://github.com/leafo/magick",
    build = "rockspec",
  },
  {
    "MunifTanjim/nui.nvim",
    -- dir = "~/projects/lua/nui.nvim/",
  },
  {
    -- "willothy/nui-components.nvim",
    "grapp-dev/nui-components.nvim",
    -- dir = "~/projects/lua/nui-components.nvim/",
  },
  {
    "kkharji/sqlite.lua",
    -- dir = "~/projects/lua/sqlite.lua/",
  },
  -- {
  --   "relua",
  --   dir = "~/projects/lua/relua/",
  --   config = function()
  --     require("relua").setup({
  --       db_path = vim.fn.stdpath("data") .. "/databases/relua.db",
  --     })
  --   end,
  --   event = "VeryLazy",
  -- },
  {
    "willothy/durable.nvim",
    dependencies = {
      "kkharji/sqlite.lua",
    },
    event = "VeryLazy",
    config = true,
  },
  "nvim-lua/plenary.nvim",
  {
    "nvim-neotest/nvim-nio",
    name = "nio",
  },
  { "nvchad/volt", lazy = true },
  -- {
  --   "willothy/libsql-lua",
  --   -- name = "libsql-lua",
  --   dir = "~/projects/cxx/libsql-lua/",
  --   -- build = "make",
  -- },
}
