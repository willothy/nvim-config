local function get_diagnostic_label(props)
	local icons = { error = "", warn = "", info = "", hint = "" }
	local label = {}

	for severity, icon in pairs(icons) do
		local n = #vim.diagnostic.get(props.buf, { severity = vim.diagnostic.severity[string.upper(severity)] })
		if n > 0 then
			table.insert(label, { icon .. " " .. n .. " ", group = "DiagnosticSign" .. severity })
		end
	end
	if #label > 0 then
		table.insert(label, { "| " })
	end
	return label
end

local function get_max_severity_group(props)
	local icons = { "hint", "info", "warn", "error" }
	local max_severity = 0
	for i, severity in ipairs(icons) do
		local n = #vim.diagnostic.get(props.buf, { severity = vim.diagnostic.severity[string.upper(severity)] })
		if n > 0 then
			max_severity = severity
		end
	end
	local severity_group = {
		"DiagnosticSignError",
		"DiagnosticSignWarn",
		"DiagnosticSignInfo",
		"DiagnosticSignHint",
	}
	return severity_group[max_severity]
end

return {
	{
		"b0o/incline.nvim",
		enabled = false,
		opts = {
			render = function(props)
				local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
				local color = get_max_severity_group({
					buf = props.buf,
				})
				local ft_icon, ft_color = require("nvim-web-devicons").get_icon_color(filename)
				local modified = vim.api.nvim_buf_get_option(props.buf, "modified") and "italic" or ""

				local buffer = {
					-- { get_diagnostic_label(props) },
					-- { get_git_diff(props) },
					-- { ft_icon, guifg = ft_color },
					-- { " " },
					-- {
					-- 	filename, --[[ gui = modified,  ]]
					-- 	guifg = color or "#1f1f1f",
					-- 	guibg = require("minimus.palette").mode_color(),
					-- },
				}
				return buffer
			end,
		},
		-- enabled = false,
	},
}
