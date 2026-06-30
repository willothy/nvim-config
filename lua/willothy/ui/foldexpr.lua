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

-- Foldexpr v2: originally lifted from nvim-treesitter/nvim-treesitter, since
-- ported to native `vim.treesitter` APIs (the nvim-treesitter `ts_utils`,
-- `query`, and `parsers` modules it used to depend on do not exist on the
-- treesitter rewrite/community fork).
--
-- Works more consistently than v1, works with large tables, but is likely slower.
local api = vim.api

---@param bufnr integer
---@return boolean
local function has_parser(bufnr)
  local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
  return ok and parser ~= nil
end

-- Collect every `@fold` (or, as a fallback, `@scope`) capture across all of a
-- buffer's language trees, recursing into injected languages. Replaces
-- nvim-treesitter's `query.get_capture_matches_recursively`.
---@param bufnr integer
---@return { node: TSNode, metadata: table? }[]
local function get_fold_matches(bufnr)
  local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
  if not ok or not parser then
    return {}
  end
  parser:parse(true)

  local matches = {}

  local function walk(ltree)
    local lang = ltree:lang()

    local capture_name, group
    if vim.treesitter.query.get(lang, "folds") then
      capture_name, group = "fold", "folds"
    elseif vim.treesitter.query.get(lang, "locals") then
      capture_name, group = "local.scope", "locals"
    end

    if capture_name then
      local q = vim.treesitter.query.get(lang, group)
      if q then
        for _, tree in pairs(ltree:trees()) do
          for id, node, metadata in
            q:iter_captures(tree:root(), bufnr, 0, -1)
          do
            if q.captures[id] == capture_name then
              matches[#matches + 1] = {
                node = node,
                metadata = metadata[id],
              }
            end
          end
        end
      end
    end

    for _, child in pairs(ltree:children()) do
      walk(child)
    end
  end

  walk(parser)

  return matches
end

-- Cache fold levels on buffer changedtick to avoid recomputing them for every
-- line in the file when e.g. `zx` is hit. Replaces nvim-treesitter's
-- `ts_utils.memoize_by_buf_tick`.
local fold_cache = {}

---@param bufnr integer
---@return string[]
local function compute_fold_levels(bufnr)
  local max_fold_level = api.nvim_get_option_value("foldnestmax", {
    win = 0,
  })
  local trim_level = function(level)
    if level > max_fold_level then
      return max_fold_level
    end
    return level
  end

  local matches = get_fold_matches(bufnr)

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
end

---@param bufnr integer
---@return string[]
local function folds_levels(bufnr)
  local tick = vim.b[bufnr].changedtick
  local cached = fold_cache[bufnr]
  if cached and cached.tick == tick then
    return cached.value
  end
  local value = compute_fold_levels(bufnr)
  fold_cache[bufnr] = { tick = tick, value = value }
  return value
end

-- free cached fold levels when a buffer is wiped
vim.api.nvim_create_autocmd("BufWipeout", {
  group = vim.api.nvim_create_augroup("willothy.foldexpr", { clear = true }),
  callback = function(args)
    fold_cache[args.buf] = nil
  end,
})

return function(lnum)
  lnum = lnum or vim.v.lnum

  local buf = api.nvim_get_current_buf()

  if lnum == nil or not has_parser(buf) then
    return "0"
  end

  local levels = folds_levels(buf)

  if not levels then
    return "0"
  end

  return levels[lnum] or "0"
end
