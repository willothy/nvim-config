return {
	{
		"desdic/greyjoy.nvim",
		config = function()
			local greyjoy = require("greyjoy")
			greyjoy.setup({
				output_results = "toggleterm",
				patterns = { ".git" },
				extensions = {
					generic = {
						commands = {
							["run {filename}"] = {
								command = { "python3", "{filename}" },
								filetype = "python",
							},
						},
					},
					cargo = {
						targets = {
							{ "build" },
							{ "build", "--release" },
							{ "check" },
							{ "clean" },
							{ "update" },
						},
					},
				},
				run_groups = {
					fast = { "generic", "makefile", "cargo" },
				},
			})

			greyjoy.load_extension("generic")
			greyjoy.load_extension("cargo")
			greyjoy.load_extension("makefile")
			greyjoy.load_extension("vscode_tasks")
		end,
	},
}
