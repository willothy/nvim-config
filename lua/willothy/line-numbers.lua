local ns = vim.api.nvim_create_namespace("comfy-ln")

local labels = {
  "1",
  "2",
  "3",
  "4",
  "5",
  "11",
  "12",
  "13",
  "14",
  "15",
  "21",
  "22",
  "23",
  "24",
  "25",
  "31",
  "32",
  "33",
  "34",
  "35",
  "41",
  "42",
  "43",
  "44",
  "45",
  "51",
  "52",
  "53",
  "54",
  "55",
}

local M = {
  config = {
    labels = labels,
    up_key = "k",
    down_key = "j",
    current_line_label = "=>",
  },
}

local n_labels = #labels

local function place_signs(win)
  win = win or vim.api.nvim_get_current_win()
  if not vim.api.nvim_win_is_valid(win) then
    return
  end

  local bufnr = vim.api.nvim_win_get_buf(win)

  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

  if
    vim.api.nvim_get_option_value("buftype", {
      buf = bufnr,
    }) ~= ""
  then
    return
  end

  local current_line = vim.api.nvim_win_get_cursor(win)[1] - 1

  for i = 1, n_labels, 1 do
    local label = labels[i]

    if current_line - i + 1 > 0 then
      vim.api.nvim_buf_set_extmark(bufnr, ns, current_line - i, 0, {
        sign_text = label,
        sign_hl_group = "LineNr",
        priority = 100,
      })
    end

    local lnr = current_line + i
    if lnr <= vim.api.nvim_buf_line_count(bufnr) then
      vim.api.nvim_buf_set_extmark(bufnr, ns, lnr, 0, {
        sign_text = label,
        sign_hl_group = "LineNr",
        priority = 100,
      })
    end
  end
end

local function update_all()
  vim.iter(vim.api.nvim_list_wins()):each(place_signs)
end

vim.api.nvim_create_autocmd(
  { "BufEnter", "CursorMoved", "CursorMovedI", "WinScrolled" },
  {
    group = vim.api.nvim_create_augroup("comfy-signs", {}),
    callback = function()
      place_signs()
    end,
  }
)
vim.schedule(update_all)

for index, label in ipairs(M.config.labels) do
  vim.keymap.set(
    { "n", "v", "o", "s" },
    label .. M.config.up_key,
    index .. "k",
    { noremap = true }
  )
  vim.keymap.set(
    { "n", "v", "o", "s" },
    label .. M.config.down_key,
    index .. "j",
    { noremap = true }
  )
end

M.ns = function()
  return ns
end

function M.hints(buf, win)
  -- vim.api.nvim_buf_set_extmark(bufnr, ns, current_line - i - 1, 0, {
  --   sign_text = label,
  --   sign_hl_group = "LineNr",
  --   priority = 100,
  -- })

  -- lnum    cursor line number
  -- col    cursor column (Note: the first column
  --     zero, as opposed to what |getcurpos()|
  --     returns)
  -- coladd    cursor column offset for 'virtualedit'
  -- curswant  column for vertical movement (Note:
  --     the first column is zero, as opposed
  --     to what |getcurpos()| returns).  After
  --     |$| command it will be a very large
  --     number equal to |v:maxcol|.
  -- topline    first line in the window
  -- topfill    filler lines, only in diff mode
  -- leftcol    first column displayed; only used when
  --     'wrap' is off
  -- skipcol    columns skipped
  local view = vim.api.nvim_win_call(win, vim.fn.winsaveview)
  local height = vim.api.nvim_win_get_height(win)

  local start = view.topline
  local final = start + height

  --  - limit:  Maximum number of marks to return
  --  - details: Whether to include the details dict
  --  - hl_name: Whether to include highlight group name instead of id, true if omitted
  --  - overlap: Also include marks which overlap the range, even if
  --             their start position is less than `start`
  --  - type: Filter marks by type: "highlight", "sign", "virt_text" and "virt_lines"
  --
  -- @*return* — List of `[extmark_id, row, col]` tuples in "traversal order".

  local extmarks = vim.api.nvim_buf_get_extmarks(
    buf,
    ns,
    { start - 1, 0 },
    { final - 1, -1 },
    {
      type = "sign",
      details = true,
      hl_name = true,
    }
  )

  local res = vim
    .iter(extmarks)
    :map(function(extmark)
      return extmark
    end)
    :fold({}, function(acc, val)
      local _, row, _col, details = unpack(val)
      acc[row] = details
      return acc
    end)

  -- if _G.X == nil and next(res) ~= nil then
  --   vim.print(res)
  --   _G.X = true
  -- end

  return res
end

return M
