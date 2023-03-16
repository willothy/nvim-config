vim.api.nvim_create_autocmd("TermOpen", {
	pattern = "term://*",
	callback = function()
		-- vim.api.nvim_feedkeys("i", "n", true)
		vim.cmd("startinsert!")
	end
})

local function split(str, c)
	local fields = {}
	for field in str:gmatch('([^' .. c .. ']+)') do
		fields[#fields + 1] = field
	end
	return fields
end

return { {
	-- terminal
	"akinsho/toggleterm.nvim",
	opts = {
		start_in_insert = true,
		winbar = {
			enabled = true,
			name_formatter = function(term)
				local id = term.name:sub( -1)
				local shellpath, _name = unpack(split(term.name, ';'))
				local shell = split(shellpath, '/')
				local hl = '%#ToggleTermName#'
				return hl .. id .. ' • ' .. shell[#shell]
			end
		}
	},
} }
