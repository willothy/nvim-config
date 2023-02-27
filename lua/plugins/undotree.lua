local function setup()
    vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)
end

return { {
    'mbbill/undotree',
    init = setup
} }
