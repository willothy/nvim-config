---@diagnostic disable: missing-fields
require("tree-sitter-just").setup({})

require("nvim-treesitter.configs").setup({
  -- A list of parser names, or "all"
  ensure_installed = {
    "query",
    "javascript",
    "typescript",
    "c",
    "cpp",
    "lua",
    "rust",
    "bash",
    "markdown",
    "markdown_inline",
    "gitcommit",
    "gitignore",
    "git_rebase",
    "git_config",
    "just",
    "jsonc",
    "json",
  },
  sync_install = false,
  auto_install = true,
  highlight = {
    enable = true,
    disable = {
      "css",
      "scss",
    },
    additional_vim_regex_highlighting = false,
  },
  indent = {
    enable = true,
  },
  textobjects = {
    select = {
      enable = true,
      lookahead = true,
      keymaps = {
        ["is"] = { query = "@statement.inner", desc = "statement" },
        ["as"] = { query = "@statement.outer", desc = "statement" },
        ["ic"] = { query = "@class.inner", desc = "class" },
        ["ac"] = { query = "@class.outer", desc = "class" },
        ["iF"] = { query = "@function.inner", desc = "function" },
        ["aF"] = { query = "@function.outer", desc = "function" },
      },
      selection_modes = {
        ["@parameter.outer"] = "v",
        -- ["@function.outer"] = "V",
        ["@class.outer"] = "<c-v>",
      },
    },
    swap = {
      enable = true,
    },
    move = {
      enable = true,
      goto_next_start = {
        ["]f"] = { query = "@function.outer", desc = "function" },
        ["]c"] = { query = "@call.outer", desc = "call" },
      },
      goto_previous_start = {
        ["[f"] = { query = "@function.outer", desc = "function" },
        ["[c"] = { query = "@call.outer", desc = "call" },
      },
    },
  },
})
-- require("treesitter.textobjects").setup()
