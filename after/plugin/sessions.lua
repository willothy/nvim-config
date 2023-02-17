local path = require('plenary.path')
local session_manager = require('session_manager')

session_manager.setup({
    sessions_dir = path:new(vim.fn.stdpath('data'), 'sessions'),
    path_replacer = '__',
    colon_replacer = '++',
    autoload_mode = require('session_manager.config').AutoloadMode.Disabled,
    autosave_last_session = true,
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
