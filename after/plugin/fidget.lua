require('fidget').setup({
    text = {
        spinner = "dots",
        done = "✓",
        commenced = "",
        completed = "✓",
    },
    window = {
        blend = 0
    }
})

require("inc_rename").setup()
vim.keymap.set("n", "<leader>rn", function()
    return ":IncRename " .. vim.fn.expand("<cword>")
end, { expr = true })
