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

    use('theprimeagen/harpoon')
    use('mbbill/undotree')
    use('tpope/vim-fugitive')

    use {
        'nvim-lualine/lualine.nvim',
        requires = { 'kyazdani42/nvim-web-devicons', opt = true }
    }

    use {
        'glepnir/dashboard-nvim',
    }

    use('lukas-reineke/lsp-format.nvim')

    use('terrortylor/nvim-comment')

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
