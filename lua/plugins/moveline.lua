local function setup()
    local moveline = require("moveline")

    vim.keymap.set("n", "<M-j>", moveline.move_line_down)
    vim.keymap.set("n", "<M-k>", moveline.move_line_up)
end

-- Moveline
return { {
    'willothy/moveline.nvim',
    build = 'make',
    config = setup,
    lazy = false,
} }
