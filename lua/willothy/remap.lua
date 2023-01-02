vim.g.mapleader = " "

function n_map(mapping, func)
    vim.keymap.set("n", mapping, func)
end

n_map("<leader>pv", vim.cmd.Ex)
