---@diagnostic disable: missing-fields
require("tree-sitter-just").setup({})

require("nvim-treesitter.configs").setup({
  -- A list of parser names, or "all"
  ensure_installed = {
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
      -- lookahead = true,
      keymaps = {
        ["is"] = "@statement.inner",
        ["as"] = "@statement.outer",
        ["ic"] = "@class.inner",
        ["ac"] = "@class.outer",
        ["if"] = "@function.inner",
        ["af"] = "@function.outer",
        ["ae"] = "@field.outer",
        ["ie"] = "@field.inner",
      },
      selection_modes = {
        ["@parameter.outer"] = "V",
        -- ["@function.outer"] = "V",
        ["@class.outer"] = "<c-v>",
      },
    },
    swap = {
      enable = false,
      swap_next = {
        ["<leader>s"] = "@parameter.inner",
      },
      swap_previous = {
        ["<leader>S"] = "@parameter.inner",
      },
    },
  },
})
