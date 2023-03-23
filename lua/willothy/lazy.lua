local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=main",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	{ import = "plugins" },
	{ import = "willothy.dev" },
	-- devicons
	"nvim-tree/nvim-web-devicons",

	{
		"dstein64/vim-startuptime",
		lazy = true,
		event = "VeryLazy",
	},

	-- Sessionista
	-- {
	--     dir = '~/projects/rust/sessionista/',
	--     lazy = true,
	-- },
	-- Crates
	{
		"saecki/crates.nvim",
		tag = "v0.3.0",
		lazy = true,
		enabled = false,
	},

	-- Transparency

	-- Status line
	{
		"willothy/lualine.nvim",
		branch = "active",
		--'nvim-lualine/lualine.nvim',
		--dir = '~/vendor/lualine.nvim/',
		dependencies = {
			"nvim-tree/nvim-web-devicons",
			dir = "~/projects/lua/minimus/",
		},
		event = "VeryLazy",
		lazy = true,
		enabled = false,
	},

	-- Neotree
	-- {
	-- 	'nvim-neo-tree/neo-tree.nvim',
	-- 	branch = "v2.x",
	-- 	dependencies = {
	-- 		"nvim-lua/plenary.nvim",
	-- 		"nvim-tree/nvim-web-devicons",
	-- 		"MunifTanjim/nui.nvim",
	-- 	},
	-- 	enabled = false,
	-- 	lazy = true,
	-- 	event = 'VeryLazy',
	-- },

	-- Neoclip
	{
		"kkharji/sqlite.lua",
		module = "sqlite",
		lazy = true,
		event = "VeryLazy",
	},
	{
		"AckslD/nvim-neoclip.lua",
		dependencies = { "kkharji/sqlite.lua", module = "sqlite" },
		config = function()
			require("neoclip").setup()
		end,
		lazy = true,
		event = "VeryLazy",
	},
	{
		"lewis6991/gitsigns.nvim",
		lazy = true,
		event = "VeryLazy",
		opts = {
			signs = {
				untracked = { text = "•" },
			},
			trouble = true,
			on_attach = function(_)
				local gs = package.loaded.gitsigns
				vim.keymap.set("n", "<leader>tb", gs.toggle_current_line_blame)
			end,
		},
	},

	-- Telescope
	"nvim-lua/popup.nvim",
	-- {
	-- 	"sudormrfbin/cheatsheet.nvim",
	-- 	config = function()
	-- 		require("cheatsheet").setup({
	-- 			bundled_cheatsheets = {
	-- 				enabled = { "default" },
	-- 			},
	-- 		})
	-- 	end,
	-- },

	-- tmux-navigator
	{
		"christoomey/vim-tmux-navigator",
		config = function() end,
	},

	-- Noice

	-- bufdelete (used to open dash when all buffers are closed)
	"famiu/bufdelete.nvim",

	-- surround
	"tpope/vim-surround",

	-- Util for commands requiring password for sudo, ssh etc.
	"lambdalisue/askpass.vim",
}, {
	-- Options
})
