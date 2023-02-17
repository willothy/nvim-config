local telescope = require('telescope')
local builtin = require('telescope.builtin')
local fb_actions = telescope.extensions.file_browser.actions
telescope.setup({
    extensions = {
        ["ui-select"] = {
            require("telescope.themes").get_dropdown({

            })
        },
        file_browser = {
            theme = "ivy",
            hijack_netrw = true,
            mappings = {
                ["i"] = {

                },
                ["n"] = {
                    ["%"] = fb_actions.create,
                    -- ["<C-n>"] = "create",
                    -- ["<C-d>"] = "remove",
                    -- ["<C-r>"] = "rename",
                    -- ["<C-y>"] = "copy",
                    -- ["<C-m>"] = "move",
                }
            }
        }
    }
})

telescope.load_extension("noice")
telescope.load_extension("ui-select")
telescope.load_extension("neoclip")
telescope.load_extension("lsp_handlers")
telescope.load_extension("command_center")
telescope.load_extension("aerial")

N_map('<leader>ff', builtin.find_files)
N_map('<C-p>', builtin.git_files)
N_map('<leader>fs', builtin.grep_string)
N_map("<leader>fb", builtin.buffers)

telescope.load_extension("file_browser")
