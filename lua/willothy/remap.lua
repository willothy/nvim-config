function N_map(mapping, func, opt)
	vim.keymap.set("n", mapping, func, opt)
end

function T_map(mapping, func, opt)
	vim.keymap.set("t", mapping, func, opt)
end

function I_map(mapping, func, opt)
	vim.keymap.set("i", mapping, func, opt)
end

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Normal
