local lnf = function(args)
	local res = require('statuscol.builtin').lnumfunc(args)
	if vim.v.relnum == 0 then
		res = res .. " "
	end
	return res
end

return { {
	'luukvbaal/statuscol.nvim',
	config = function()
		local statuscol = require("statuscol")
		local builtin = require("statuscol.builtin")
		statuscol.setup({
			relculright = true,
			segments = {
				{ text = { "%C" },  click = "v:lua.ScFa" },
				{ text = { " %s" }, click = "v:lua.ScSa" },
				{
					text = { lnf, " " },
					condition = { true, builtin.not_empty },
					click = "v:lua.ScLa",
				}
			}
		})
	end,
} }
