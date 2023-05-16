local function setup()
	local dap = require("dap")

	dap.configurations.rust = {
		{
			name = "Launch",
			type = "codelldb",
			request = "launch",
			program = function()
				return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
			end,
			cwd = "${workspaceFolder}",
			stopOnEntry = false,
			args = {},
		},
	}
	dap.adapters.codelldb = {
		type = "server",
		port = "${port}",
		executable = {
			command = "/home/willothy/.local/share/nvim/mason/bin/codelldb",
			args = { "--port", "${port}" },
		},
	}
end

return {
	{
		"mfussenegger/nvim-dap",
		config = setup,
	},
	{
		"rcarriga/nvim-dap-ui",
		dependencies = {
			"mfussenegger/nvim-dap",
		},
		config = true,
	},
	-- others
}
