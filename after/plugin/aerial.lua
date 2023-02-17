require('aerial').setup({
    dense = true,
    depth = 5
})

vim.keymap.set("n", "<leader>o", function()
    require('aerial').toggle()
end)
