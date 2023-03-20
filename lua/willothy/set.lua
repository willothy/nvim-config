vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = -1
vim.opt.shiftwidth = 0
vim.opt.expandtab = false

vim.opt.smartindent = true

vim.opt.wrap = true

vim.g.rust_recommended_style = 1

vim.opt.swapfile = true
vim.opt.backup = false
--vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 16
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50
vim.opt.colorcolumn = "0"

vim.api.nvim_create_autocmd("BufEnter", {
	callback = function()
		if HasValue({ "floaterm", "toggleterm", "dashboard", "alpha" }, GetBufType()) then
			return
		end

		local ok, _ = pcall(vim.cmd, 'Gcd')
		if ok == false then
			vim.cmd("lcd %:p:h")
		end
	end
})
