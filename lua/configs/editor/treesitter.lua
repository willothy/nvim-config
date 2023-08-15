require("nvim-treesitter").setup({
  -- A list of parser names, or "all"
  ensure_installed = {
    "help",
    "javascript",
    "typescript",
    "c",
    "cpp",
    "lua",
    "rust",
    "bash",
    "markdown",
    "markdown_inline",
  },
  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,
  -- Automatically install missing parsers when entering buffer
  -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
  auto_install = true,
  highlight = {
    -- `false` will disable the whole extension
    enable = true,
    disable = {},
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
        -- ["is"] = { query = "@statement.inner", query_group = "locals" },
        -- ["as"] = { query = "@statement.outer", query_group = "locals" },
        -- ["is"] = { query = "@scope.inner", query_group = "locals" },
        -- ["as"] = { query = "@scope.outer", query_group = "locals" },
        -- ["ic"] = { query = "@class.inner", query_group = "locals" },
        -- ["ac"] = { query = "@class.outer", query_group = "locals" },
        ["if"] = "@function.inner",
        ["af"] = "@function.outer",
        -- ["ip"] = { query = "@property.inner", query_group = "locals" },
        -- ["ap"] = { query = "@property.outer", query_group = "locals" },
      },
      selection_modes = {
        ["@parameter.outer"] = "V",
        -- ["@function.outer"] = "V",
        ["@class.outer"] = "<c-v>",
      },
    },
    swap = {
      enable = true,
      swap_next = {
        ["<leader>s"] = "@parameter.inner",
      },
      swap_previous = {
        ["<leader>S"] = "@parameter.inner",
      },
    },
  },
})
