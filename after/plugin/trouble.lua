require('trouble').setup({})

vim.keymap.set("n", "T", ":TroubleToggle document_diagnostics<CR>")
