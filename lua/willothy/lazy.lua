local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath
    })
end
vim.opt.rtp:prepend(lazypath)

return require('lazy').setup({
    -- devicons
    'nvim-tree/nvim-web-devicons',

    -- Impatient
    'lewis6991/impatient.nvim',

    -- Color themes
    'connorholyday/vim-snazzy',
    'AlexvZyl/nordic.nvim',
    'olivercederborg/poimandres.nvim',
    'rktjmp/lush.nvim',
    { dir = '~/projects/lua/minimus' },
    {
        'catppuccin/nvim',
        as = 'catppuccin'
    },

    -- Transparency
    'xiyaowong/nvim-transparent',

    -- Dashboard
    {
        'goolord/alpha-nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
    },

    {
        'norcalli/nvim-colorizer.lua',
        config = function()
            --require('colorizer').setup()
        end
    },

    'ziontee113/color-picker.nvim',

    -- Status line
    {
        'willothy/lualine.nvim',
        branch = "active",
        --'nvim-lualine/lualine.nvim',
        --dir = '~/vendor/lualine.nvim/',
        dependencies = { 'nvim-tree/nvim-web-devicons' }
    },

    -- Neotree
    {
        'nvim-neo-tree/neo-tree.nvim',
        branch = "v2.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
            "MunifTanjim/nui.nvim",
        },
    },

    -- Neoclip
    {
        'kkharji/sqlite.lua',
        module = 'sqlite'
    },
    {
        'AckslD/nvim-neoclip.lua',
        dependencies = { 'kkharji/sqlite.lua', module = 'sqlite' },
        config = function()
            require('neoclip').setup()
        end
    },
    {
        'lewis6991/gitsigns.nvim',
        config = function()
            require('gitsigns').setup({
                on_attach = function(_)
                    local gs = package.loaded.gitsigns
                    vim.keymap.set("n", "<leader>tb", gs.toggle_current_line_blame)
                end
            })
        end
    },

    -- Telescope
    {
        'nvim-telescope/telescope.nvim',
        tag = '0.1.0',
        dependencies = { 'nvim-lua/plenary.nvim' },
    },
    {
        'gbrlsnchs/telescope-lsp-handlers.nvim',
        dependencies = { 'nvim-telescope/telescope.nvim' }
    },
    {
        'nvim-telescope/telescope-ui-select.nvim',
        dependencies = { 'nvim-telescope/telescope.nvim' }
    },
    {
        'nvim-telescope/telescope-file-browser.nvim',
        dependencies = { 'nvim-telescope/telescope.nvim' }
    },
    {
        'FeiyouG/command_center.nvim',
        dependencies = { "nvim-telescope/telescope.nvim" }
    },
    'nvim-lua/popup.nvim',
    {
        'sudormrfbin/cheatsheet.nvim',
        config = function()
            require('cheatsheet').setup({
                bundled_cheatsheets = {
                    enabled = { 'default' },
                }
            })
        end
    },

    -- Copilot
    'github/copilot.vim',

    -- LSP
    'stevearc/aerial.nvim',
    'SmiteshP/nvim-navic',
    {
        'utilyre/barbecue.nvim',
        tag = "v0.3.1",
        dependencies = {
            "SmiteshP/nvim-navic",
            "nvim-tree/nvim-web-devicons",
        },
    },
    'lvimuser/lsp-inlayhints.nvim', -- LSP inlay hints
    'lukas-reineke/lsp-format.nvim', -- LSP formatting
    'j-hui/fidget.nvim', -- LSP progress
    {
        'VonHeikemen/lsp-zero.nvim',
        dependencies = {
            -- LSP Support
            'neovim/nvim-lspconfig',
            'williamboman/mason.nvim',
            'williamboman/mason-lspconfig.nvim',

            -- Autocompletion
            'hrsh7th/nvim-cmp',
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-path',
            'hrsh7th/cmp-cmdline',
            'saadparwaiz1/cmp_luasnip',
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-nvim-lua',

            -- Snippets
            'L3MON4D3/LuaSnip',
            'rafamadriz/friendly-snippets',
        }
    },

    -- tmux-navigator
    {
        'christoomey/vim-tmux-navigator',
        config = function()

        end
    },

    -- sessions
    {
        'Shatur/neovim-session-manager',
        dependencies = { 'nvim-lua/plenary.nvim' }
    },

    -- Noice
    'MunifTanjim/nui.nvim',
    'rcarriga/nvim-notify',
    'smjonas/inc-rename.nvim',
    {
        'folke/noice.nvim',
        dependencies = {
            'MunifTanjim/nui.nvim',
            'rcarriga/nvim-notify'
        }
    },

    -- bufdelete (used to open dash when all buffers are closed)
    'famiu/bufdelete.nvim',

    -- surround
    'tpope/vim-surround',

    -- mini.nvim
    'echasnovski/mini.trailspace',
    'echasnovski/mini.tabline',
    'echasnovski/mini.sessions',
    'echasnovski/mini.map',
    'echasnovski/mini.jump',
    'echasnovski/mini.indentscope',
    'echasnovski/mini.cursorword',

    -- treesitter
    { 'nvim-treesitter/nvim-treesitter', build = ':TSUpdate' },
    'nvim-treesitter/playground',

    -- terminal
    "akinsho/toggleterm.nvim",

    -- Shortcuts
    'theprimeagen/harpoon',

    -- Undos
    'mbbill/undotree',

    -- Git integration
    'tpope/vim-fugitive',
    {
        "folke/trouble.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
    },

    -- Util for commands requiring password for sudo, ssh etc.
    'lambdalisue/askpass.vim',

    -- Utils / misc
    'numToStr/Comment.nvim',
    'windwp/nvim-autopairs',

    -- Discord rich presence (for the lols)
    'andweeb/presence.nvim',
})
