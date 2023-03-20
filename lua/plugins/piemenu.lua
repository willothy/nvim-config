vim.opt.mouse = 'a'

local function init()
	local Pie = require('piemenu').register
	local group = vim.api.nvim_create_augroup("piemenu_setting", {})
	vim.api.nvim_create_autocmd({ "FileType" }, {
		group = group,
		pattern = { "piemenu" },
		callback = function()
			vim.o.mousemoveevent = true
			vim.keymap.set("n", "<MouseMove>", require("piemenu").highlight, { buffer = true })
			vim.keymap.set("n", "<LeftDrag>", require("piemenu").highlight, { buffer = true })
			vim.keymap.set("n", "<LeftRelease>", require("piemenu").finish, { buffer = true })
			vim.keymap.set("n", "<RightMouse>", require("piemenu").cancel, { buffer = true })
		end,
	})

	vim.keymap.set("n", "<RightMouse>", Wrap(require('piemenu').start, "main"))

	Pie("main", {
		menus = {
			{
				text = "📋 copy",
				action = function()
					vim.cmd.normal({ args = { "yy" }, bang = true })
				end,
			},
			{
				text = "📝 paste",
				action = function()
					vim.cmd.normal({ args = { "p" }, bang = true })
				end,
			},
			{
				text = "✅ save",
				action = function()
					vim.cmd.write()
				end,
			},
		}
	})
end

return { {
	'notomo/piemenu.nvim',
	lazy = false,
	-- event = 'BufEnter',
	init = init,
	enabled = false,
} }
