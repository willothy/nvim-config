return { {
    'tamton-aquib/flirt.nvim',
    config = function()
        require("flirt").setup({
            override_open = false,
            default_move_mappings = false,
            default_resize_mappings = false,
        })
    end,
    lazy = true,
    event = 'VeryLazy'
} }
