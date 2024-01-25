local a = require("nio")

local defer = a.sleep

local function tmp_buf(text)
  if type(text) == "string" then
    text = { text }
  end
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, text)
  return buf
end

local STAGE_DELAY = 1500
-- local STAGE_DELAY = 10

a.run(function()
  local initial_win = vim.api.nvim_get_current_win()
  local buf
  buf = tmp_buf({ "this is split 1", "a right-aligned top-level window" })
  local win = vim.api.nvim_open_win(buf, false, {
    split = "right",
  })
  defer(STAGE_DELAY)

  buf = tmp_buf({ "this is split 2", "positioned below split 1" })
  local win2 = vim.api.nvim_open_win(buf, false, {
    split = "below",
    win = win,
  })
  defer(STAGE_DELAY)

  vim.api.nvim_win_set_buf(
    win2,
    tmp_buf({
      "this is split 2",
      "initially positioned below split 1",
      "its width has been decreased",
    })
  )
  vim.api.nvim_win_set_config(win2, {
    width = 50,
    -- height = 50,
  })
  defer(STAGE_DELAY)

  vim.api.nvim_win_set_buf(
    win,
    tmp_buf({
      "this is split 1",
      "it started right-aligned",
      "it is now left-aligned",
    })
  )
  vim.api.nvim_win_set_config(win, {
    split = "left",
  })
  defer(STAGE_DELAY)

  buf = tmp_buf({
    "this is split 3",
    "it is a top-level split at the top of the screen",
  })
  local win3 = vim.api.nvim_open_win(buf, false, {
    split = "above",
    win = -1,
  })
  defer(STAGE_DELAY)

  buf = tmp_buf({
    "this is a float",
    "that will become a split",
  })
  local float = vim.api.nvim_open_win(buf, false, {
    relative = "editor",
    width = 40,
    height = 20,
    col = math.floor(vim.o.columns / 2) - 20,
    row = math.floor(vim.o.lines / 2) - 10,
  })
  defer(STAGE_DELAY)

  vim.api.nvim_win_set_buf(
    float,
    tmp_buf({
      "this is a float",
      "that has become a split",
      "it is now right-aligned",
    })
  )
  vim.api.nvim_win_set_config(float, {
    split = "right",
    win = -1,
  })
  defer(STAGE_DELAY)

  require("focus").focus_equalise()

  vim.keymap.set("n", "<Esc>", function()
    vim.api.nvim_set_current_win(initial_win)
    for _, win in ipairs({
      win,
      win2,
      win3,
      float,
    }) do
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
    end
  end, { nowait = true })
end)
