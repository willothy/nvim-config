local path = require('plenary.path')
local session_manager = require('session_manager')

session_manager.setup({
    sessions_dir = path:new(vim.fn.stdpath('data'), 'sessions'),
    path_replacer = '__',
    colon_replacer = '++',
    autoload_mode = require('session_manager.config').AutoloadMode.Disabled,
    autosave_last_session = false,
    autosave_ignore_not_normal = false,
    autosave_ignore_filetypes = {
        'gitcommit',
    },
    autosave_ignore_buftypes = {
        'alpha',
        'floatterm',
        'toggleterm',
        'trouble',
        'terminal',
        'packer',
        'mason',
        'TelescopePrompt',
        'telescope',
    },
})

local sessions_group = vim.api.nvim_create_augroup('SessionsConfigGroup', {})

-- local possession = require("nvim-possession")
-- possession.setup({
--     sessions = {
--         sessions_path = path:new(vim.fn.stdpath('data'), 'sessions'),
--         sessions_icon = '',
--         autoswitch = {
--             enable = true,
--         },
--     }
-- })
-- N_map("<leader>ls", function() possession.list() end)
-- N_map("<leader>sn", function() possession.new() end)
-- N_map("<leader>ss", function() possession.update() end)
N_map("<leader>sn", ":SessionManager new_session<CR>")
N_map("<leader>ss", ":SessionManager save_current_session<CR>")
N_map("<leader>sl", ":SessionManager load_session<CR>")
N_map("<leader>ll", ":SessionManager load_last_session<CR>")
N_map("<leader>sd", ":SessionManager delete_session<CR>")
