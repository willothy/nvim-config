local focus = require("focus")

local group = vim.api.nvim_create_augroup("focus_ft", { clear = true })
local disable = {
  ["neo-tree"] = true,
  ["SidebarNvim"] = true,
  ["Trouble"] = true,
  ["terminal"] = true,
  ["dapui_console"] = true,
  ["dapui_watches"] = true,
  ["dapui_stacks"] = true,
  ["dapui_breakpoints"] = true,
  ["dapui_scopes"] = true,
  ["dap-repl"] = true,
  ["NeogitStatus"] = true,
  ["NeogitLogView"] = true,
  ["NeogitPopup"] = true,
  ["NeogitCommitMessage"] = true,
}
vim.api.nvim_create_autocmd("FileType", {
  group = group,
  callback = function(ev)
    local ft = vim.bo[ev.buf].filetype
    if disable[ft] then
      vim.b.focus_disable = true
    end
  end,
  desc = "Disable focus autoresize for FileType",
})

focus.setup({
  ui = {
    cursorline = false,
    signcolumn = false,
    winhighlight = false,
  },
  autoresize = {
    -- width = 180,
    -- minwidth = 200,
    animation = {
      enable = false,
      easing = "linear",
    },
  },
})
