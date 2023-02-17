function N_map(mapping, func)
    vim.keymap.set("n", mapping, func)
end

function T_map(mapping, func)
    vim.keymap.set("t", mapping, func)
end

function I_map(mapping, func)
    vim.keymap.set("i", mapping, func)
end

vim.g.mapleader = " "
vim.g.maplocalleader = " "

N_map("<leader>fn", ":enew<CR>")
N_map("<leader>ls", ":SessionManager load_session<CR>")
N_map("<leader>ll", ":SessionManager load_last_session<CR>")
N_map("<leader>ss", ":SessionManager save_current_session<CR>")
N_map("<leader>pf", ":Browse ~/projects<CR>")
N_map("<leader>nv", ":Browse ~/.config/nvim/<CR>")
N_map("<leader>D", ":Alpha<CR>")
N_map("<leader>pv", ":Telescope file_browser<CR>")
vim.keymap.set('i', '<S-Tab>', '<Plug>(copilot-suggest)', { silent = true })
