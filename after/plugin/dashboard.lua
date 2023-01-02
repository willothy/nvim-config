local home = os.getenv('HOME')
local api = vim.api
local db = require('dashboard')
local db_session = require('dashboard.session')

vim.g.dashboard_default_executive = 'telescope'

db.session_verbose = false
db.custom_header = {
    '', '', '',
    '███▄    █ ▓█████  ▒█████   ██▒   █▓ ██▓ ███▄ ▄███▓ ',
    '██ ▀█   █ ▓█   ▀ ▒██▒  ██▒▓██░   █▒▓██▒▓██▒▀█▀ ██▒ ',
    '▓██  ▀█ ██▒▒███   ▒██░  ██▒ ▓██  █▒░▒██▒▓██    ▓██░',
    '▓██▒  ▐▌██▒▒▓█  ▄ ▒██   ██░  ▒██ █░░░██░▒██    ▒██ ',
    '▒██░   ▓██░░▒████▒░ ████▓▒░   ▒▀█░  ░██░▒██▒   ░██▒',
    '░ ▒░   ▒ ▒ ░░ ▒░ ░░ ▒░▒░▒░    ░ ▐░  ░▓  ░ ▒░   ░  ░',
    '░ ░░   ░ ▒░ ░ ░  ░  ░ ▒ ▒░    ░ ░░   ▒ ░░  ░      ░',
    '░   ░ ░    ░   ░ ░ ░ ▒       ░░   ▒ ░░      ░      ',
    '░    ░  ░    ░ ░        ░   ░         ░            ',
    '░                                                  ',
    '', '',
}

vim.api.nvim_set_hl(0, "DashboardHeader", { fg = "#5089fa", bg = "none" })

db.custom_center = {
    {
        desc = 'Create a new file                       ',
        shortcut = 'SPC f n',
        action = 'DashboardNewFile'
    },
    {
        desc = 'Open last session                       ',
        shortcut = 'SPC s l',
        action = 'SessionLoad'
    },
    {
        desc = 'Projects                                ',
        action = 'Projects',
        shortcut = 'SPC p f'
    },
    {
        desc = 'Edit Neovim Config                      ',
        action = 'edit ~/.config/nvim/',
        shortcut = 'SPC n v'
    },
}

db.session_directory = home .. '/.vim/sessions'
db.session_auto_save_on_exit = true

local dashboard_start = api.nvim_create_augroup('dashboard_start', { clear = true })

api.nvim_create_autocmd('Vimenter', {
    group = dashboard_start,
    nested = true,
    callback = function()
        if vim.fn.argc() == 0 and vim.fn.line2byte('$') == -1 and not db.disable_at_vimenter then
            db:instance(true)
        end
    end,
})

api.nvim_create_autocmd('FileType', {
    group = dashboard_start,
    pattern = 'dashboard',
    callback = function()
        if db.hide_statusline then
            vim.opt.laststatus = 0
        end

        if db.hide_tabline then
            vim.opt.showtabline = 0
        end

        if vim.fn.has('nvim-0.8') == 1 then
            if db.hide_winbar then
                vim.opt.winbar = ''
            end
        end
    end,
})

if db.session_auto_save_on_exit then
    local session_auto_save = api.nvim_create_augroup('session_auto_save', { clear = true })

    api.nvim_create_autocmd('VimLeavePre', {
        group = session_auto_save,
        callback = function()
            if db_session.should_auto_save() then
                api.nvim_exec_autocmds('User', { pattern = 'DBSessionSavePre', modeline = false })
                db_session.session_save()
                api.nvim_exec_autocmds('User', { pattern = 'DBSessionSaveAfter', modeline = false })
            end
        end,
    })
end

api.nvim_create_user_command('Projects', function()
    api.nvim_set_current_dir("~/Projects")
    vim.cmd.Ex()
end, {})

api.nvim_create_user_command('Dashboard', function()
    require('dashboard'):instance(false)
end, {})

api.nvim_create_user_command('DashboardNewFile', function()
    require('dashboard').new_file()
end, {})

api.nvim_create_user_command('SessionSave', function()
    require('dashboard.session').session_save()
end,
    { nargs = '?', complete = require('dashboard.session').session_list, }
)

vim.keymap.set("n", "<leader>fn", ":DashboardNewFile<CR>")
vim.keymap.set("n", "<leader>sl", ":SessionLoad<CR>")
vim.keymap.set("n", "<leader>pf", ":Projects<CR>")
vim.keymap.set("n", "<leader>nv", ":edit ~/.config/nvim/<CR>")
vim.keymap.set("n", "<leader>D", ":Dashboard<CR>")
