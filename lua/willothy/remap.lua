vim.g.mapleader = " "

function n_map(mapping, func)
    vim.keymap.set("n", mapping, func)
end

function t_map(mapping, func)
    vim.keymap.set("t", mapping, func)
end

function mode()
    return vim.api.nvim_get_mode()["mode"]
end

function print_mode() print(vim.api.nvim_get_mode()["mode"]) end

n_map("<leader>pv", vim.cmd.Ex)
