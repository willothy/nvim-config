local files = require("mini.files")

files.setup({
  windows = {
    preview = false,
    width_focus = 25,
    width_preview = 40,
    border = "solid",
  },
})

local harpoon = function(buf)
  return function()
    local mode = vim.fn.mode()
    local win = vim.api.nvim_get_current_win()
    if mode == "n" then
      local cursor = vim.api.nvim_win_get_cursor(win)
      local file = files.get_fs_entry(buf, cursor[1])
      require("harpoon.mark").toggle_file(file.path)
    elseif mode == "v" or mode == "V" then
      vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "x", false)
      local start = vim.api.nvim_buf_get_mark(0, "<")[1]
      local finish = vim.api.nvim_buf_get_mark(0, ">")[1]

      local add_marks = require("harpoon.mark").toggle_file
      for i = start, finish do
        local file = files.get_fs_entry(buf, i)
        add_marks(file.path)
      end
    end
  end
end

vim.api.nvim_create_autocmd("User", {
  pattern = "MiniFilesBufferCreate",
  callback = function(ev)
    local buf = ev.data.buf_id

    vim.keymap.set("n", "<Esc>", files.close, { buffer = buf })
    vim.keymap.set("n", "<CR>", files.go_in, { buffer = buf })
    vim.keymap.set({ "n", "v" }, "<Tab>", harpoon(buf), { buffer = buf })
  end,
})
