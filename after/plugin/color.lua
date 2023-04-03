if vim.g.minimal then
	return
end

function Highlight(mode, group, opt)
	vim.api.nvim_set_hl(mode, group, opt)
end

function SetupColor(color)
	local p = require("minimus.palette").hex
	local ns = vim.api.nvim_create_namespace("willothy-hl")
	vim.api.nvim_set_hl(ns, "LspInlayHint", {
		fg = p.cadet_gray,
		bg = p.none,
	})
	vim.api.nvim_set_hl(ns, "ToggleTermName", {
		fg = p.cool_gray,
		bg = p.none,
	})
	vim.api.nvim_set_hl(ns, "LazyNormal", {
		fg = p.cool_gray,
		bg = p.none,
		blend = 100,
	})
	vim.cmd("colorscheme " .. color)
end

SetupColor("minimus")
