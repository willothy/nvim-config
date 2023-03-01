local function setup()
    local moveline = require("moveline")

    vim.keymap.set("n", "<M-j>", moveline.down)
    vim.keymap.set("n", "<M-k>", moveline.up)

    vim.keymap.set("v", "<M-k>", moveline.block_up)
    vim.keymap.set("v", "<M-j>", moveline.block_down)
end

-- Moveline
return { {
    'willothy/moveline.nvim',
    dir = '~/projects/neovim/moveline/',
    build = 'make',
    config = setup,
    lazy = false,
} }
