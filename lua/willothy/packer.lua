vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
    use 'wbthomason/packer.nvim'
    use {
        'nvim-telescope/telescope.nvim',
        tag = '0.1.0',
        requires = { { 'nvim-lua/plenary.nvim' } }
    }
    use('nvim-tree/nvim-web-devicons')
    use('lvimuser/lsp-inlayhints.nvim')
    use('connorholyday/vim-snazzy')

    use('nvim-telescope/telescope-ui-select.nvim')

    -- tmux-navigator
    use('christoomey/vim-tmux-navigator')

    -- sessions
    use('Shatur/neovim-session-manager', {
        requires = { 'nvim-lua/plenary.nvim' }
    })

    use('famiu/bufdelete.nvim')

    -- surround
    use('tpope/vim-surround')

    -- transparent
    use('xiyaowong/nvim-transparent')

    -- mini.nvim
    use('echasnovski/mini.trailspace')
    use('echasnovski/mini.tabline')
    use('echasnovski/mini.sessions')
    use('echasnovski/mini.map')
    use('echasnovski/mini.jump')
    use('echasnovski/mini.indentscope')
    use('echasnovski/mini.cursorword')

    use('nvim-treesitter/nvim-treesitter', { run = ':TSUpdate' })
    use('nvim-treesitter/playground')

    use('voldikss/vim-floaterm')
    use('theprimeagen/harpoon')
    use('mbbill/undotree')
    use('tpope/vim-fugitive')

    use {
        'nvim-lualine/lualine.nvim',
        requires = { 'kyazdani42/nvim-web-devicons', opt = true }
    }

    -- buggy
    --[[ use {
        'glepnir/dashboard-nvim',
        requires = { 'nvim-tree/nvim-web-devicons' }
    } ]]

    use('goolord/alpha-nvim', {
        requires = { 'nvim-tree/nvim-web-devicons' },
    })

    use {
        'glepnir/dbsession.nvim',
        event = 'BufRead',
        cmd = 'SessionSave',
        config = function()
            require('dbsession').setup({
                auto_save_on_exit = true
            })
        end
    }

    use('lukas-reineke/lsp-format.nvim')

    -- Didn't have support for visual select
    -- use('terrortylor/nvim-comment')
    use('numToStr/Comment.nvim')

    use('andweeb/presence.nvim')

    -- use('unblevable/quick-scope')

    use {
        'VonHeikemen/lsp-zero.nvim',
        requires = {
            -- LSP Support
            { 'neovim/nvim-lspconfig' },
            { 'williamboman/mason.nvim' },
            { 'williamboman/mason-lspconfig.nvim' },

            -- Autocompletion
            { 'hrsh7th/nvim-cmp' },
            { 'hrsh7th/cmp-buffer' },
            { 'hrsh7th/cmp-path' },
            { 'saadparwaiz1/cmp_luasnip' },
            { 'hrsh7th/cmp-nvim-lsp' },
            { 'hrsh7th/cmp-nvim-lua' },

            -- Snippets
            { 'L3MON4D3/LuaSnip' },
            { 'rafamadriz/friendly-snippets' },
        }
    }

    use({
        "folke/trouble.nvim",
        requires = "kyazdani42/nvim-web-devicons",
    })

    use('windwp/nvim-autopairs')

    use { "akinsho/toggleterm.nvim", tag = '*' }
end)
