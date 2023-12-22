local foldinfos

for i = 1, 5 do
  -- hacky way to get the foldinfos table
  -- I do not want to reimplement treesitter folding myself lol
  local name, val =
    debug.getupvalue(require("vim.treesitter._fold").foldexpr, i)
  if name == "foldinfos" then
    foldinfos = val
    break
  end
end

---@param lnum? integer
---@return string
return function(lnum)
  local ts = vim.treesitter.foldexpr(lnum)

  -- fallback to default treesitter foldexpr if we
  -- can't find the foldinfos table in its upvalues
  if not foldinfos then
    return ts
  end

  lnum = lnum or vim.v.lnum
  local bufnr = vim.api.nvim_get_current_buf()

  if not foldinfos[bufnr] then
    return ts
  end

  ---@type TS.FoldInfo
  local info = foldinfos[bufnr]

  local fold_raw = info.levels0[lnum]
  if not fold_raw then
    return "0"
  end

  local next_raw = info.levels0[lnum + 1]
  if next_raw and next_raw < fold_raw then
    return tostring(math.max(0, fold_raw - 1))
  end

  return info.levels[lnum] or "0"
end
