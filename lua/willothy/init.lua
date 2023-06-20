if vim.g.minimal ~= nil then
	require("willothy.minimal")
	return
end

_G.dbg = vim.print

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- require("willothy.test")
require("willothy.util")
require("willothy.lazy")
require("willothy.lsp")
require("willothy.set")

vim.api.nvim_create_user_command("Detach", function()
	local uis = vim.api.nvim_list_uis()
	if #uis < 1 then
		return
	end
	local chan = uis[1].chan
	vim.fn.chanclose(chan)
end, {})

-- File for messing around with lua
-- require("willothy.scratchpad")
-- require("willothy.sessions")

--vim.g.rust_conceal = 1
--vim.g.rust_recommended_style = 0
