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

-- Normal
N_map("<leader>fn", ":enew<CR>")
N_map("<leader>pf", Wrap(Browse, "~/projects"))
N_map("<leader>nv", Wrap(Browse, Wrap(vim.fn.stdpath, 'config')))
N_map("<leader>fv", function() Browse(GetParentPath(vim.fn.expand('%'))) end)
N_map("<leader>pv", Wrap(Browse))
N_map("<leader>vv", function()
    vim.ui.input({ prompt = 'Path: ' }, function(input)
        Browse(input)
    end)
end)
N_map("<leader>D", ":Alpha<CR>")

-- Insert
-- vim.keymap.set('i', '<S-Tab>', '<Plug>(copilot-suggest)', { silent = true })

-- Terminal
T_map("<Esc>", "<C-\\><C-n>")
T_map("<C-w><Up>", "<C-\\><C-n><C-w>k")
T_map("<C-w><Down>", "<C-\\><C-n><C-w>j")
T_map("<C-w><Left>", "<C-\\><C-n><C-w>h")
T_map("<C-w><Right>", "<C-\\><C-n><C-w>l")
T_map("<C-w>k", "<C-\\><C-n><C-w>k")
T_map("<C-w>j", "<C-\\><C-n><C-w>j")
T_map("<C-w>h", "<C-\\><C-n><C-w>h")
T_map("<C-w>l", "<C-\\><C-n><C-w>l")
