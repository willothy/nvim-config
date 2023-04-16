-- INFO This method is necessary as opposed to a simple `:find`, to correctly
-- determine a word the
-- cursor is already standing on
---@param line string
---@param pattern string
---@param endOfWord boolean look for the end of the pattern instead of the start
---@param col number -- look for the first match after this number
---@nodiscard
---@return number|nil returns nil if none is found
local function firstMatchAfter(line, pattern, endOfWord, col)
	-- special case: pattern with ^/$, since there can only be one match
	-- and since gmatch won't work with them
	if pattern:find("^%^") or pattern:find("%$$") then
		if pattern:find("%$$") and col >= #line then
			return nil
		end -- checking for high col count for virtualedit
		if pattern:find("^%^") and col ~= 1 then
			return nil
		end
		local start, endPos = line:find(pattern)
		local pos = endOfWord and endPos or start
		if pos and not endOfWord then
			pos = pos - 1
		end
		return pos
	end

	if endOfWord then
		pattern = pattern .. "()" -- INFO "()" makes gmatch return the position of that group
	else
		pattern = "()" .. pattern
	end
	-- `:gmatch` will return all locations in the string where the pattern is
	-- found, the loop looks for the first one that is higher than the col to
	-- look from
	for pos in line:gmatch(pattern) do
		if endOfWord and pos > col then
			return pos - 1
		end
		if not endOfWord and pos >= col then
			return pos - 1
		end
	end
	return nil
end

---finds next word, which is lowercase, uppercase, or standalone punctuation
---@param line string input string where to find the pattern
---@param col number position to start looking from
---@param key "w"|"e"|"b"|"ge" the motion to perform
---@nodiscard
---@return number|nil pattern position, returns nil if no pattern was found
local function getNextPosition(line, col, key)
	-- `%f[set]` is roughly lua's equivalent of `\b`
	local patterns = {
		lowerWord = "%u?[%l%d]+", -- first char may be uppercase for CamelCase
		upperWord = "%f[%w][%u%d]+%f[^%w]", -- solely uppercase for SCREAMING_SNAKE_CASE
		punctuation = "%f[^%s]%p+%f[%s]", -- punctuation surrounded by whitespace
		punctAtStart = "^%p+%f[%s]", -- needed since lua does not allow for logical OR
		punctAtEnd = "%f[^%s]%p+$",
		onlyPunct = "^%p+$",
	}
	-- if not skipInsignificantPunc then
	-- 	patterns.punctuation = "%p+"
	-- end

	-- define motion properties
	local backwards = (key == "b") or (key == "ge")
	local endOfWord = (key == "ge") or (key == "e")
	if backwards then
		patterns.lowerWord = "[%l%d]+%u?" -- the other patterns are already symmetric
		line = line:reverse()
		endOfWord = not endOfWord
		if col == -1 then
			col = 1
		else
			col = #line - col + 1
		end
	end

	-- search for patterns, get closest one
	local matches = {}
	for _, pattern in pairs(patterns) do
		local match = firstMatchAfter(line, pattern, endOfWord, col)
		if match then
			table.insert(matches, match)
		end
	end
	if vim.tbl_isempty(matches) then
		return nil
	end -- none found in this line
	local nextPos = math.min(unpack(matches))

	if not endOfWord then
		nextPos = nextPos + 1
	end
	if backwards then
		nextPos = #line - nextPos + 1
	end
	return nextPos
end

local function next_n_positions(lines, col, n, startline)
	local key = "w"
	local positions = {}

	for linenr, line in ipairs(lines) do
		local c = linenr == 1 and col or 0
		local p = getNextPosition(line, c, key)
		while p ~= nil and #positions < n do
			table.insert(positions, { line = startline + linenr, col = p, char = string.char(string.byte(line, p)) })
			c = p + 1
			p = getNextPosition(line, c, key)
		end
		if #positions >= n then
			break
		end
	end
	return positions
end

local function make_positions_unique(positions)
	local unique = {}
	vim.print(positions)
	for i, pos in ipairs(positions) do
		if unique[pos.char] == nil then
			-- unique[pos.char] = true
			rawset(unique, pos.char, { line = pos.line, col = pos.col })
		else
			table.remove(positions, i)
		end
	end
	local res = {}
	for _, pos in pairs(unique) do
		table.insert(res, pos)
	end
	-- vim.print(unique)
	return res
end

local function get_positions()
	local cursor = vim.api.nvim_win_get_cursor(0)
	local col = cursor[2]
	local lines = vim.api.nvim_buf_get_lines(0, cursor[1] - 1, -1, false)
	local positions = next_n_positions(lines, col, 10, cursor[1] - 1)
	positions = make_positions_unique(positions)
	return positions
end

local ns = vim.api.nvim_create_namespace("leap_willothy")

local function hl_positions(positions, n)
	for i, pos in ipairs(positions) do
		if n and i > n then
			break
		end
		vim.api.nvim_buf_add_highlight(0, ns, "LeapMatch", pos.line - 1, pos.col, pos.col + 1)
	end
end

local function clear_hl()
	vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
end

local function find_hl()
	clear_hl()
	local positions = get_positions()
	hl_positions(positions)
end

return {
	{
		"ggandor/leap.nvim",
		-- dependencies = {
		-- 	"jinh0/eyeliner.nvim",
		-- },
		config = true,
	},
	{
		-- personal fork with eyeliner highlighting
		"willothy/flit.nvim",
		-- "ggandor/flit.nvim",
		dir = "~/projects/lua/flit.nvim/",
		opts = {
			keys = { f = "f", F = "F", t = "t", T = "T" },
			-- A string like "nv", "nvo", "o", etc.
			labeled_modes = "v",
			multiline = true,
			-- Like `leap`s similar argument (call-specific overrides).
			-- E.g.: opts = { equivalence_classes = {} }
			opts = {},
		},
	},
}
