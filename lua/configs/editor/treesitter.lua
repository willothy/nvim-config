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
  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,
  -- Automatically install missing parsers when entering buffer
  -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
  auto_install = true,
  highlight = {
    -- `false` will disable the whole extension
    enable = true,
    disable = {
      "lua", -- lua treesitter highlight is buggy
      "css",
      "scss",
    },
    -- list of language that will be disabled
    -- additional_vim_regex_highlighting = true,
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
      swap_next = {
        -- ["]z"] = { query = "@scope", desc = "swap" },
        -- ["]z"] = {
        --   query = "@field.outer",
        --   desc = "Select language scope",
        -- },
      },
      swap_previous = {
        -- ["[z"] = { query = "(field) @field", desc = "swap" },
      },
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
