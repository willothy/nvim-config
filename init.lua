-- if vim.g.neovide then
-- 	vim.o.guifont = "FireCode Nerd Font:h14"
-- end
vim.loader.enable()
-- package.path = package.path .. ";/home/willothy/.luarocks/share/lua/5.1/?.lua"
-- vim.api.nvim_create_autocmd("UiEnter", {
-- 	once = true,
-- 	callback = function()
-- 		require("tl").loader()
-- 	end,
-- })
require("willothy")
