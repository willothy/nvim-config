-- Author: Willothy
--
-- `vim.treesitter.foldtext()`, extended to preserve inlay hints and semantic highlighting.

local api = vim.api
local ts = vim.treesitter

return function()
  local foldstart = vim.v.foldstart
  local bufnr = vim.api.nvim_get_current_buf()

  ---@type boolean, LanguageTree
  local ok, parser = pcall(ts.get_parser, bufnr)
  if not ok then
    return vim.fn.foldtext()
  end

  local query = ts.query.get(parser:lang(), "highlights")
  if not query then
    return vim.fn.foldtext()
  end

  local tree = parser:parse({ foldstart - 1, foldstart })[1]

  local line =
    api.nvim_buf_get_lines(bufnr, foldstart - 1, foldstart, false)[1]
  if not line then
    return vim.fn.foldtext()
  end

  ---@type { [1]: string, [2]: string[], range: { [1]: integer, [2]: integer } }[] | { [1]: string, [2]: string[] }[]
  local result = {}

  local line_pos = 0

  for id, node, metadata in
    query:iter_captures(tree:root(), 0, foldstart - 1, foldstart)
  do
    local name = query.captures[id]
    local start_row, start_col, end_row, end_col = node:range()

    local priority =
      tonumber(metadata.priority or vim.highlight.priorities.treesitter)

    if start_row == foldstart - 1 and end_row == foldstart - 1 then
      -- check for characters ignored by treesitter
      if start_col > line_pos then
        table.insert(result, {
          line:sub(line_pos + 1, start_col),
          {},
          range = { line_pos, start_col },
        })
      end
      line_pos = end_col

      -- get possible semantic highlight for the symbol
      local extmarks = vim.api.nvim_buf_get_extmarks(
        bufnr,
        -1,
        { foldstart - 1, start_col - 1 },
        { foldstart - 1, end_col - 1 },
        {
          details = true,
          hl_name = true,
          type = "highlight",
        }
      )
      -- ensure priority sort (buf_get_extmarks returns "traversal order")
      table.sort(extmarks, function(a, b)
        return a[4].priority < b[4].priority
      end)
      local extmark_hl = extmarks[1]

      local text = line:sub(start_col + 1, end_col)
      local highlights = {
        { "@" .. name, extmark_hl and (priority - 1) or priority },
        extmark_hl and { extmark_hl[4].hl_group, priority },
      }
      table.insert(
        result,
        { text, highlights, range = { start_col, end_col } }
      )
    end
  end

  local i = 1
  while i <= #result do
    -- find first capture that is not in current range and apply highlights on the way
    local j = i + 1
    while
      j <= #result
      and result[j].range[1] >= result[i].range[1]
      and result[j].range[2] <= result[i].range[2]
    do
      for k, v in ipairs(result[i][2]) do
        if not vim.tbl_contains(result[j][2], v) then
          table.insert(result[j][2], k, v)
        end
      end
      j = j + 1
    end

    -- remove the parent capture if it is split into children
    if j > i + 1 then
      table.remove(result, i)
    else
      -- highlights need to be sorted by priority, on equal prio, the deeper nested capture (earlier
      -- in list) should be considered higher prio
      if #result[i][2] > 1 then
        table.sort(result[i][2], function(a, b)
          return a[2] < b[2]
        end)
      end

      result[i][2] = vim.tbl_map(function(tbl)
        return tbl[1]
      end, result[i][2])
      result[i] = { result[i][1], result[i][2] }

      i = i + 1
    end
  end

  local extmarks = vim.api.nvim_buf_get_extmarks(
    0,
    -1,
    { foldstart - 1, 1 },
    { foldstart - 1, -1 },
    {
      details = true,
      hl_name = true,
      type = "virt_text",
    }
  )

  local merged_vt = {}
  local last_found = 0

  -- merge inline extmarks into the line's virt text chunks
  for _, mark in ipairs(extmarks) do
    if mark[4].virt_text and mark[4].virt_text_pos == "inline" then
      local virt_text = mark[4].virt_text --[[@as any[] ]]
      local col_start = mark[3] --[[@as integer]]
      local cur_width = 0
      for idx, res_chunk in ipairs(result) do
        cur_width = cur_width + #res_chunk[1]
        if cur_width >= col_start then
          if idx > last_found then
            table.insert(merged_vt, res_chunk)
          end
          last_found = idx
          for _, vt in ipairs(virt_text) do
            table.insert(merged_vt, vt)
          end
          break
        end
        if idx > last_found then
          table.insert(merged_vt, res_chunk)
        end
      end
    end
  end

  -- add the remaining virt text chunks to the result
  for idx = last_found + 1, #result do
    table.insert(merged_vt, result[idx])
  end

  return merged_vt
end
