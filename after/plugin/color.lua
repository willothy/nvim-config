function Highlight(mode, group, opt)
	vim.api.nvim_set_hl(mode, group, opt)
end

-- require("catppuccin").setup({
-- 	transparent_background = true,
-- 	term_colors = true,
-- 	styles = {
-- 		comments = {}
-- 	},
-- 	integrations = {
-- 		cmp = true,
-- 		gitsigns = true,
-- 		telescope = true,
-- 		notify = true,
-- 		mini = true,
-- 		fidget = true,
-- 		harpoon = true,
-- 		mason = true,
-- 		noice = true,
-- 		neotree = true,
-- 		treesitter = true,
-- 		lsp_trouble = true,
-- 		which_key = true,
-- 		aerial = true,
-- 		semantic_tokens = true,
-- 		barbecue = {
-- 			dirname = true,
-- 		},
-- 		native_lsp = {
-- 			enabled = true,
-- 			virtual_text = {
-- 				errors = {},
-- 				hints = { "italic" },
-- 				warnings = {},
-- 				information = {}
-- 			},
-- 			underlines = {
-- 				errors = {},
-- 				hints = {},
-- 				warnings = {},
-- 				information = {}
-- 			}
-- 		}
-- 	}
-- })

function SetupColor(color)
	local p = require("minimus.palette").hex
	local ns = vim.api.nvim_create_namespace("willothy-hl")
	vim.api.nvim_set_hl(ns, "ToggleTermName", {
		fg = p.cool_gray, bg = p.none
	})
end

SetupColor("minimus")
