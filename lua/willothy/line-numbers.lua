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

local function place_signs()
  local win = vim.api.nvim_get_current_win()
  local bufnr = vim.api.nvim_win_get_buf(win)

  if
    vim.api.nvim_get_option_value("buftype", {
      buf = bufnr,
    }) ~= ""
  then
    return
  end

  local current_line = vim.api.nvim_win_get_cursor(win)[1]

  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

  for i = 1, n_labels, 1 do
    local label = labels[i]

    if current_line - i > 0 then
      vim.api.nvim_buf_set_extmark(bufnr, ns, current_line - i - 1, 0, {
        sign_text = label,
        sign_hl_group = "LineNr",
        priority = 100,
      })
    end

    local lnr = current_line + i - 1
    if lnr <= vim.api.nvim_buf_line_count(bufnr) then
      vim.api.nvim_buf_set_extmark(bufnr, ns, lnr, 0, {
        sign_text = label,
        sign_hl_group = "LineNr",
        right_gravity = true,
        priority = 100,
      })
    end
  end
end

vim.api.nvim_create_autocmd({ "BufEnter", "CursorMoved", "CursorMovedI" }, {
  group = vim.api.nvim_create_augroup("comfy-signs", {}),
  callback = vim.schedule_wrap(place_signs),
})
vim.schedule(place_signs)

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

return M
