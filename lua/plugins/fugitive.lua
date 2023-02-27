local function setup()
    vim.keymap.set("n", "<leader>gs", vim.cmd.Git)
end

return { {
    'tpope/vim-fugitive',
    init = setup
} }
