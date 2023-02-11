local builtin = require('telescope.builtin')
n_map('<leader>ff', builtin.find_files, {})
n_map('<C-p>', builtin.git_files, {})
n_map('<leader>fs', builtin.grep_string)
n_map("<leader>fb", builtin.buffers)

require("telescope").setup({
    extensions = {
        ["ui-select"] = {
            require("telescope.themes").get_dropdown({

            })
        }
    }
})

require("telescope").load_extension("ui-select")
