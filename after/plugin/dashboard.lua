local home = os.getenv('HOME')
local api = vim.api
local icons = require('nvim-web-devicons')
local db = require('dashboard')

db.setup({
    theme = 'doom',
    config = {
        header = {
            '', '', '', '', '', '',
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
        },
        -- packages = { enable = true },
        --project = { limit = 2, icon = '{}', action = 'Telescope find_files' },
        --mru = { limit = 2, icon = '[]' },
        --footer = { "" },
        center = {
            {
                icon = icons.get_icon("doc", "doc", {}) .. ' ',
                desc = "Create a new file",
                key = 'f',
                keymap = "SPC f n",
                action = "enew"
            },
            {
                icon = icons.get_icon('diff', 'diff', {}) .. ' ',
                desc = 'Open last session',
                key = 's',
                keymap = 'SPC s l',
                action = 'SessionLoad'
            },
            {
                icon = icons.get_icon('git', 'git', {}) .. ' ',
                desc = 'Projects',
                action = 'Projects',
                key = 'w',
                keymap = 'SPC p f'
            },
            {
                icon = icons.get_icon('vim', 'vim', {}) .. ' ',
                desc = 'Edit Neovim Config',
                action = 'edit ~/.config/nvim/',
                key = 'c',
                keymap = 'SPC n v'
            },
        }
    }
})
-- local db_session = require('dbsession').setup({})

vim.g.dashboard_default_executive = 'telescope'

vim.api.nvim_set_hl(0, "DashboardHeader", { fg = "#5089fa", bg = "none" })

-- db.session_directory = home .. '/.vim/sessions'
-- db.session_auto_save_on_exit = true

local dashboard_start = api.nvim_create_augroup('dashboard_start', { clear = true })

-- api.nvim_create_autocmd('Vimenter', {
--     group = dashboard_start,
--     nested = true,
--     callback = function()
--         if vim.fn.argc() == 0 and vim.fn.line2byte('$') == -1 and not db.disable_at_vimenter then
--             db:instance(true)
--         end
--     end,
-- })

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

api.nvim_create_user_command('Projects', function()
    api.nvim_set_current_dir("~/Projects")
    vim.cmd.Ex()
end, {})

vim.keymap.set("n", "<leader>fn", ":DashboardNewFile<CR>")
--vim.keymap.set("n", "<leader>sl", ":SessionLoad<CR>")
vim.keymap.set("n", "<leader>pf", ":Projects<CR>")
vim.keymap.set("n", "<leader>nv", ":edit ~/.config/nvim/<CR>")
vim.keymap.set("n", "<leader>D", ":Dashboard<CR>")
