function GetBufType()
	return vim.bo.filetype
end

function HasValue(arr, val)
	for _, value in ipairs(arr) do
		if value == val then
			return true
		end
	end
	return false
end

require("willothy.util")
require("willothy.remap")
require("willothy.set")
require("willothy.lazy")

-- File for messing around with lua
require("willothy.scratchpad")
-- require("willothy.sessions")

vim.g.rust_conceal = 1
vim.g.rust_recommended_style = 0
