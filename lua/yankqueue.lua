---@class YankQueue
local YankQueue = {}
YankQueue.__index = YankQueue

function YankQueue:new()
	return setmetatable({}, YankQueue)
end

function YankQueue:push(item)
	table.insert(self, item)
end

function YankQueue:pop()
	return table.remove(self, 1)
end

function YankQueue:peek()
	return self[1]
end

function YankQueue:is_empty()
	return #self == 0
end

return {
	setup = function()
		_G.yank_queue = YankQueue:new()

		vim.api.nvim_create_autocmd("TextYankPost", {
			pattern = "*",
			group = vim.api.nvim_create_augroup("yankqueue", { clear = true }),
			callback = function(ev)
				local reg = vim.fn.getreg('"')
				if reg == "" then
					return
				end
				_G.yank_queue:push(reg)
			end,
		})

		vim.keymap.set("n", "<leader>yp", function()
			local reg = _G.yank_queue:peek()
			if reg == nil then
				return
			end
			vim.fn.setreg('"', reg)
			vim.cmd([[normal! p]])
		end)

		vim.keymap.set("n", "<leader>yP", function()
			local reg = _G.yank_queue:pop()
			if reg == nil then
				return
			end
			vim.fn.setreg('"', reg)
			vim.cmd([[normal! P]])
		end)

		vim.keymap.set("n", "<leader>yy", function()
			local reg = vim.fn.getreg('"')
			if reg == "" then
				return
			end
			_G.yank_queue:push(reg)
		end)
	end,
	YankQueue = YankQueue,
}
