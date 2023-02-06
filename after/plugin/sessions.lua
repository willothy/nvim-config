local path = require('plenary.path')
local session_manager = require('session_manager')

session_manager.setup({
    sessions_dir = path:new(vim.fn.stdpath('data'), 'sessions'),
    path_replacer = '__',
    colon_replacer = '++',
    autoload_mode = require('session_manager.config').AutoloadMode.Disabled,
    autosave_last_session = true,
    autosave_ignore_not_normal = true,
    autosave_ignore_filetypes = {
        'gitcommit',
    },
    autosave_ignore_buftypes = {
        'alpha',
        'floatterm',
        'toggleterm',
        'trouble'
    },
})

local sessions_group = vim.api.nvim_create_augroup('SessionsConfigGroup', {})

vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
    group = sessions_group,
    callback = function()
        if vim.bo.filetype ~= 'git' and not vim.bo.filetype ~= 'gitcommit' then
            session_manager.autosave_session()
        end
    end
})
