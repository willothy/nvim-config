return {
  "famiu/bufdelete.nvim",
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
