return {
	{
		"willothy/veil.nvim",
		-- config = true,
		enabled = false,
		dir = "~/projects/lua/veil/",
		-- enabled = false,
		-- enabled = false,
		-- enabled = false,
		-- dir = vim.g.dev == "veil" and "~/projects/neovim/veil.nvim/" or nil,
		-- config = true,
		-- 	config = function()
		-- 		local veil = require("veil")
		-- 		local builtin = require("veil.builtin")
		-- 		local default = require("veil.default")
		--
		-- 		default.sections[2] = builtin.sections.buttons({
		-- 			{
		-- 				icon = "",
		-- 				text = "Projects",
		-- 				shortcut = "p",
		-- 				callback = function()
		-- 					require("telescope").extensions.file_browser.file_browser({
		-- 						prompt_title = "Projects",
		-- 						cwd = "~/projects/",
		-- 					})
		-- 				end,
		-- 			},
		-- 			{
		-- 				icon = "",
		-- 				text = "Find Files",
		-- 				shortcut = "f",
		-- 				callback = function()
		-- 					require("telescope.builtin").find_files()
		-- 				end,
		-- 			},
		-- 			{
		-- 				icon = "",
		-- 				text = "Find Word",
		-- 				shortcut = "w",
		-- 				callback = function()
		-- 					require("telescope.builtin").live_grep()
		-- 				end,
		-- 			},
		-- 			{
		-- 				icon = "",
		-- 				text = "Buffers",
		-- 				shortcut = "b",
		-- 				callback = function()
		-- 					require("telescope.builtin").buffers()
		-- 				end,
		-- 			},
		-- 			{
		-- 				icon = "",
		-- 				text = "Config",
		-- 				shortcut = "c",
		-- 				callback = function()
		-- 					require("telescope").extensions.file_browser.file_browser({
		-- 						path = vim.fn.stdpath("config"),
		-- 					})
		-- 				end,
		-- 			},
		-- 		})
		-- 		veil.setup(default)
		-- 	end,
		-- },
	},
}
