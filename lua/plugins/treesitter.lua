local opts = {
    -- A list of parser names, or "all"
    ensure_installed = {
        "help", "javascript", "typescript",
        "c", "cpp", "lua", "rust", "bash"
    },
    -- Install parsers synchronously (only applied to `ensure_installed`)
    sync_install = true,
    -- Automatically install missing parsers when entering buffer
    -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
    auto_install = true,
    highlight = {
        -- `false` will disable the whole extension
        enable = true,
        -- list of language that will be disabled
        additional_vim_regex_highlighting = false
    },
    textobjects = {
        select = {
            enable = true,
            lookahead = true,
            keymaps = {
                ["af"] = "@function.outer",
                ["if"] = "@function.inner",
                ["ac"] = "@class.outer",
                ["ic"] = "@class.inner",
                ["as"] = { query = "@scope", query_group = "locals" }
            },
            selection_modes = {
                ['@parameter.outer'] = 'V',
                ['@function.outer'] = 'V',
                ['@class.outer'] = '<c-v>'
            },
        },
        swap = {
            enable = true,
            swap_next = {
                ["<leader>s"] = "@parameter.inner",
            },
            swap_previous = {
                ["<leader>S"] = "@parameter.inner"
            }
        }
    }
}

return {
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        dependencies = {
            'nvim-treesitter/nvim-treesitter-textobjects'
        },
        lazy = true,
        opts = opts
    }
}
