if vim.g.minimal ~= nil then
	require("willothy.minimal")
	return
end

_G.dbg = vim.print

require("willothy.util")
require("willothy.remap")
require("willothy.set")
require("willothy.lazy")
-- require("willothy.lsp")

-- File for messing around with lua
-- require("willothy.scratchpad")
-- require("willothy.sessions")

--vim.g.rust_conceal = 1
--vim.g.rust_recommended_style = 0
