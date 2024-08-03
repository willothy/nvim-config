local files = require("mini.files")

files.setup({
  windows = {
    preview = false,
    width_focus = 25,
    width_nofocus = 25,
    width_preview = 25,
    height_focus = 20,
    border = "solid",
    max_number = 3,
  },
  use_as_default_explorer = false,
})

local Path = require("plenary.path")

local harpoon = function(buf)
  return function()
    local mode = vim.fn.mode()
    local win = vim.api.nvim_get_current_win()
    local list = require("harpoon"):list("files")
    local root = files.get_latest_path()
    if mode == "n" then
      local cursor = vim.api.nvim_win_get_cursor(win)
      local file = files.get_fs_entry(buf, cursor[1])
      if file then
        list:add({
          value = Path:new(file.path):make_relative(root),
          context = {
            row = 1,
            col = 1,
          },
        })
      end
    elseif mode == "v" or mode == "V" then
      vim.cmd.normal(vim.keycode("<Esc>"))
      local start = vim.api.nvim_buf_get_mark(0, "<")[1]
      local finish = vim.api.nvim_buf_get_mark(0, ">")[1]

      for i = start, finish do
        local file = files.get_fs_entry(buf, i)
        if file then
          list:add({
            value = Path:new(file.path):make_relative(root),
            context = {
              row = 1,
              col = 1,
            },
          })
        end
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

vim.api.nvim_create_user_command("MiniFiles", function(args)
  local path = args.fargs[1]
  require("mini.files").open(path)
end, {
  desc = "Open mini.files",
  nargs = "?",
})
