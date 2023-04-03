-- local lnf = function(args)
-- 	local res = require("statuscol.builtin").lnumfunc(args)
-- 	if vim.v.relnum == 0 then
-- 		res = res .. " "
-- 	end
-- 	return res
-- end
--
-- return {}

return {
	{
		"lewis6991/gitsigns.nvim",
		lazy = false,
		opts = {
			signs = {
				untracked = { text = "•" },
			},
			trouble = true,
			signcolumn = true,
			-- on_attach = function(_)
			-- 	local gs = package.loaded.gitsigns
			-- 	vim.keymap.set("n", "<leader>tb", gs.toggle_current_line_blame)
			-- end,
		},
		config = true,
		-- event = { "LspAttach" },
	},
	{
		"luukvbaal/statuscol.nvim",
		-- dir = "~/projects/neovim/statuscol.nvim",
		dependencies = {
			"lewis6991/gitsigns.nvim",
		},
		lazy = false,
		config = function()
			local peek = require("blam").peek
			local blame = function(args)
				local line = args.mousepos.line
				peek(line)
			end

			local builtin = require("statuscol.builtin")
			require("statuscol").setup({
				relculright = true,
				segments = {
					{
						sign = {
							name = { "GitSigns*" },
							maxwidth = 1,
							-- colwidth = 1,
						},
						click = "v:lua.ScSa",
					},
					{
						sign = {
							-- name = { "Diagnostic" },
							name = { ".*" },
							maxwidth = 1,
							-- colwidth = 1,
							-- auto = true,
						},
						click = "v:lua.ScSa",
					},
					{
						text = { builtin.lnumfunc, " " },
						condition = { builtin.not_empty, true },
						click = "v:lua.ScLa",
					},
					{
						text = { builtin.foldfunc, " " },
						click = "v:lua.ScFa",
					},
				},
				clickhandlers = {
					-- Lnum = builtin.lnum_click,
					-- FoldClose = builtin.foldclose_click,
					-- FoldOpen = builtin.foldopen_click,
					-- FoldOther = builtin.foldother_click,
					-- DapBreakpointRejected = false, -- builtin.toggle_breakpoint,
					-- DapBreakpoint = false, --builtin.toggle_breakpoint,
					-- DapBreakpointCondition = false, -- builtin.toggle_breakpoint,
					-- DiagnosticSignError = builtin.diagnostic_click,
					-- DiagnosticSignHint = builtin.diagnostic_click,
					-- DiagnosticSignInfo = builtin.diagnostic_click,
					-- DiagnosticSignWarn = builtin.diagnostic_click,
					GitSignsTopdelete = blame,
					GitSignsUntracked = blame,
					GitSignsAdd = blame,
					GitSignsChange = blame,
					GitSignsChangedelete = blame,
					GitSignsDelete = blame,
					-- FoldOther = false, -- Disable builtin clickhandler
					-- Lnum = function(args)
					-- 	if args.button == "l" and args.mods:find("c") then
					-- 		print("I Ctrl-left clicked on line " .. args.mousepos.line)
					-- 	end
					-- end,
				},
			})
		end,
	},
}
