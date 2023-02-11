vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
    use 'wbthomason/packer.nvim'

    -- devicons
    use('nvim-tree/nvim-web-devicons')

    -- Color themes
    use('connorholyday/vim-snazzy')
    use('AlexvZyl/nordic.nvim')
    use('olivercederborg/poimandres.nvim')
    use('rktjmp/lush.nvim')
    use('uloco/bluloco.nvim', {
        requires = { 'rktjmp/lush.nvim' }
    })

    -- Transparency
    use('xiyaowong/nvim-transparent')

    -- Dashboard
    use('goolord/alpha-nvim', {
        requires = { 'nvim-tree/nvim-web-devicons' },
    })

    -- Status line
    use {
        'nvim-lualine/lualine.nvim',
        requires = { 'kyazdani42/nvim-web-devicons', opt = true }
    }

    -- Telescope
    use {
        'nvim-telescope/telescope.nvim',
        tag = '0.1.0',
        requires = { { 'nvim-lua/plenary.nvim' } }
    }
    use('nvim-telescope/telescope-ui-select.nvim')

    -- LSP
    use('lvimuser/lsp-inlayhints.nvim')
    use('lukas-reineke/lsp-format.nvim')
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

    -- tmux-navigator
    use('christoomey/vim-tmux-navigator', {
        config = function()

        end
    })

    -- sessions
    use('Shatur/neovim-session-manager', {
        requires = { 'nvim-lua/plenary.nvim' }
    })

    -- bufdelete (used to open dash when all buffers are closed)
    use('famiu/bufdelete.nvim')

    -- surround
    use('tpope/vim-surround')

    -- mini.nvim
    use('echasnovski/mini.trailspace')
    use('echasnovski/mini.tabline')
    use('echasnovski/mini.sessions')
    use('echasnovski/mini.map')
    use('echasnovski/mini.jump')
    use('echasnovski/mini.indentscope')
    use('echasnovski/mini.cursorword')

    -- treesitter
    use('nvim-treesitter/nvim-treesitter', { run = ':TSUpdate' })
    use('nvim-treesitter/playground')

    -- terminal (TODO: Find a better terminal plugin)
    use('voldikss/vim-floaterm')
    use { "akinsho/toggleterm.nvim" }

    -- Shortcuts
    use('theprimeagen/harpoon')

    -- Undos
    use('mbbill/undotree')

    -- Git integration
    use('tpope/vim-fugitive')
    use({
        "folke/trouble.nvim",
        requires = "kyazdani42/nvim-web-devicons",
    })



    -- Utils / misc
    use('numToStr/Comment.nvim')
    use('windwp/nvim-autopairs')

    -- Discord rich presence (for the lols)
    use('andweeb/presence.nvim')
end)
