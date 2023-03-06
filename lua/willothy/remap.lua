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
N_map("<leader>fn", ":enew<CR>", {
	desc = "Create a new buffer"
})
N_map("<leader>pf", Wrap(Browse, "~/projects"), {
	desc = "Browse projects"
})
N_map("<leader>nv", Wrap(Browse, Wrap(vim.fn.stdpath, 'config')), {
	desc = "Browse nvim config"
})
N_map("<leader>fv", function() Browse(GetParentPath(vim.fn.expand('%'))) end, {
	desc = "Browse current file's directory"
})
N_map("<leader>pv", Wrap(Browse), {
	desc = "Browse current directory"
})
N_map("<leader>vv", function()
	vim.ui.input({ prompt = 'Path: ' }, function(input)
		Browse(input)
	end)
end, {
	desc = "Browse path"
})
N_map("<leader>D", ":Alpha<CR>", {
	desc = "Return to dashboard"
})
N_map("<leader>w", function() vim.api.nvim_exec("w", true) end, {
	desc = "Save"
})

-- Insert

-- Terminal
T_map("<Esc>", "<C-\\><C-n>", {
	desc = "Exit terminal mode"
})
T_map("<C-w><Up>", "<C-\\><C-n><C-w>k", {
	desc = "Move to window above"
})
T_map("<C-w><Down>", "<C-\\><C-n><C-w>j", {
	desc = "Move to window below"
})
T_map("<C-w><Left>", "<C-\\><C-n><C-w>h", {
	desc = "Move to window left"
})
T_map("<C-w><Right>", "<C-\\><C-n><C-w>l", {
	desc = "Move to window right"
})
T_map("<C-w>k", "<C-\\><C-n><C-w>k", {
	desc = "Move to window above"
})
T_map("<C-w>j", "<C-\\><C-n><C-w>j", {
	desc = "Move to window below"
})
T_map("<C-w>h", "<C-\\><C-n><C-w>h", {
	desc = "Move to window left"
})
T_map("<C-w>l", "<C-\\><C-n><C-w>l", {
	desc = "Move to window right"
})
