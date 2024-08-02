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

local function place_signs()
  local current_file = vim.fn.expand("%")
  if current_file == nil or current_file == "" then
    return
  end

  vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)

  local current_line = vim.api.nvim_win_get_cursor(0)[1]

  for i = 1, #M.config.labels, 1 do
    local label = M.config.labels[i]

    if current_line - i > 0 then
      vim.api.nvim_buf_set_extmark(0, ns, current_line - i - 1, 0, {
        sign_text = label,
        sign_hl_group = "LineNr",
        priority = 100,
      })
    end

    local lnr = current_line + i - 1
    if lnr <= vim.api.nvim_buf_line_count(0) then
      vim.api.nvim_buf_set_extmark(0, ns, lnr, 0, {
        sign_text = label,
        sign_hl_group = "LineNr",
        priority = 100,
      })
    end
  end
end

vim.api.nvim_create_autocmd({ "BufEnter", "CursorMoved", "CursorMovedI" }, {
  group = vim.api.nvim_create_augroup("comfy-signs", {}),
  callback = vim.schedule_wrap(place_signs),
})

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

vim.schedule(place_signs)

return M
