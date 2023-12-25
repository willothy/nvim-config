-- Foldexpr v1: largely based on `vim.treesitter.foldexpr`, and works by
-- hijacking its upvalues to get the foldinfos table.
--
-- local foldinfos
--
-- for i = 1, 5 do
--   -- hacky way to get the foldinfos table
--   -- I do not want to reimplement treesitter folding myself lol
--   local name, val =
--     debug.getupvalue(require("vim.treesitter._fold").foldexpr, i)
--   if name == "foldinfos" then
--     foldinfos = val
--     break
--   end
-- end
--
-- ---
-- ---This works for things that end with 'end', but not for tables.
--
-- ---@param lnum? integer
-- ---@return string
-- return function(lnum)
--   local ts = vim.treesitter.foldexpr(lnum)
--
--   -- fallback to default treesitter foldexpr if we
--   -- can't find the foldinfos table in its upvalues
--   if not foldinfos then
--     return ts
--   end
--
--   lnum = lnum or vim.v.lnum
--   local bufnr = vim.api.nvim_get_current_buf()
--
--   if not foldinfos[bufnr] then
--     return ts
--   end
--
--   ---@type TS.FoldInfo
--   local info = foldinfos[bufnr]
--
--   local fold_raw = info.levels0[lnum]
--   if not fold_raw then
--     return "0"
--   end
--
--   local next_raw = info.levels0[lnum + 1]
--   if next_raw and next_raw < fold_raw then
--     return tostring(math.max(0, fold_raw - 1))
--   end
--
--   return info.levels[lnum] or "0"
-- end

-- Foldexpr v2: largely lifted from nvim-treesitter/nvim-treesitter
--
-- Works more consistently than v1, works with large tables, but is likely slower.
local api = vim.api
local tsutils, query, parsers
local folds_levels

local function init()
  tsutils = require("nvim-treesitter.ts_utils")
  query = require("nvim-treesitter.query")
  parsers = require("nvim-treesitter.parsers")

  -- This is cached on buf tick to avoid computing that multiple times
  -- Especially not for every line in the file when `zx` is hit
  folds_levels = tsutils.memoize_by_buf_tick(function(bufnr)
    local max_fold_level = api.nvim_get_option_value("foldnestmax", {
      win = 0,
    })
    local trim_level = function(level)
      if level > max_fold_level then
        return max_fold_level
      end
      return level
    end

    local parser = parsers.get_parser(bufnr)

    if not parser then
      return {}
    end

    local matches = query.get_capture_matches_recursively(bufnr, function(lang)
      if query.has_folds(lang) then
        return "@fold", "folds"
      elseif query.has_locals(lang) then
        return "@scope", "locals"
      end
    end)

    -- start..stop is an inclusive range

    ---@type table<number, number>
    local start_counts = {}
    ---@type table<number, number>
    local stop_counts = {}

    local prev_start = -1
    local prev_stop = -1

    local min_fold_lines = api.nvim_get_option_value("foldminlines", {
      win = 0,
    })

    for _, match in ipairs(matches) do
      local start, stop, stop_col ---@type integer, integer, integer
      if match.metadata and match.metadata.range then
        start, _, stop, stop_col = unpack(match.metadata.range) ---@type integer, integer, integer, integer
      else
        start, _, stop, stop_col = match.node:range() ---@type integer, integer, integer, integer
      end

      -- Show the last line of the fold (foldtext already shows the first line)
      stop = math.max(start, stop - 1)

      if stop_col == 0 then
        stop = stop - 1
      end

      local fold_length = stop - start + 1
      local should_fold = fold_length > min_fold_lines

      -- Fold only multiline nodes that are not exactly the same as previously met folds
      -- Checking against just the previously found fold is sufficient if nodes
      -- are returned in preorder or postorder when traversing tree
      if should_fold and not (start == prev_start and stop == prev_stop) then
        start_counts[start] = (start_counts[start] or 0) + 1
        stop_counts[stop] = (stop_counts[stop] or 0) + 1
        prev_start = start
        prev_stop = stop
      end
    end

    ---@type string[]
    local levels = {}
    local current_level = 0

    -- We now have the list of fold opening and closing, fill the gaps and mark where fold start
    for lnum = 0, api.nvim_buf_line_count(bufnr) do
      local prefix = ""

      local last_trimmed_level = trim_level(current_level)
      current_level = current_level + (start_counts[lnum] or 0)
      local trimmed_level = trim_level(current_level)
      current_level = current_level - (stop_counts[lnum] or 0)
      local next_trimmed_level = trim_level(current_level)

      -- Determine if it's the start/end of a fold
      -- NB: vim's fold-expr interface does not have a mechanism to indicate that
      -- two (or more) folds start at this line, so it cannot distinguish between
      --  ( \n ( \n )) \n (( \n ) \n )
      -- versus
      --  ( \n ( \n ) \n ( \n ) \n )
      -- If it did have such a mechanism, (trimmed_level - last_trimmed_level)
      -- would be the correct number of starts to pass on.
      if trimmed_level - last_trimmed_level > 0 then
        prefix = ">"
      elseif trimmed_level - next_trimmed_level > 0 then
        -- Ending marks tend to confuse vim more than it helps, particularly when
        -- the fold level changes by at least 2; we can uncomment this if
        -- vim's behavior gets fixed.
        -- prefix = "<"
        prefix = ""
      end

      levels[lnum + 1] = prefix .. tostring(trimmed_level)
    end

    return levels
  end)
end

return function(lnum)
  if not tsutils then
    init()
  end

  lnum = lnum or vim.v.lnum

  if lnum == nil or not parsers.has_parser() then
    return "0"
  end

  local buf = api.nvim_get_current_buf()

  local levels = folds_levels(buf)

  if not levels then
    return "0"
  end

  return levels[lnum] or "0"
end
