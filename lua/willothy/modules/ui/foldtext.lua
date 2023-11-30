-- Author: Willothy
--
-- Virtual text preserving treesitter foldtext, similar to nvim-ufo

return function()
  local foldstart = vim.v.foldstart

  local ts_fold_vt = vim.treesitter.foldtext()

  if type(ts_fold_vt) == "string" then
    return ts_fold_vt
  end

  local merged_vt = {}
  local last_found = 0
  vim
    .iter(
      vim.api.nvim_buf_get_extmarks(
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
    )
    :filter(function(mark)
      return mark[4].virt_text_pos == "inline"
    end)
    :each(function(mark)
      local virt_text = mark[4].virt_text
      local col_start = mark[3]
      local cur_width = 0
      for i, res_chunk in ipairs(ts_fold_vt) do
        cur_width = cur_width + #res_chunk[1]
        if cur_width >= col_start then
          if i > last_found then
            table.insert(merged_vt, res_chunk)
          end
          last_found = i
          for _, vt in ipairs(virt_text) do
            table.insert(merged_vt, vt)
          end
          break
        end
        if i > last_found then
          table.insert(merged_vt, res_chunk)
        end
      end
    end)

  for i = last_found + 1, #ts_fold_vt do
    table.insert(merged_vt, ts_fold_vt[i])
  end

  return merged_vt
end
