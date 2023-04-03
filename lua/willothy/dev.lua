if vim.g.minimal then
	require("willothy.set")
	return {
		-- {
		-- 	"willothy/veil.nvim",
		-- 	config = true,
		-- },
		{ import = "plugins.statuscol" },
	}
end
return {}
