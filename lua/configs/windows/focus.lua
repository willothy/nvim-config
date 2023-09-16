local focus = require("focus")

local ignore_filetypes = {
  ["neo-tree"] = true,
  ["dap-repl"] = true,
  SidebarNvim = true,
  Trouble = true,
  terminal = true,
  dapui_console = true,
  dapui_watches = true,
  dapui_stacks = true,
  dapui_breakpoints = true,
  dapui_scopes = true,
  NeogitStatus = true,
  NeogitLogView = true,
  NeogitPopup = true,
  NeogitCommitMessage = true,
  OverseerList = true,
}

focus.setup({
  ui = {
    cursorline = false,
    signcolumn = false,
    winhighlight = false,
  },
  autoresize = {
    center_hsplits = false,
  },
})

vim.api.nvim_create_autocmd("FileType", {
  callback = function()
    vim.w.focus_disable = ignore_filetypes[vim.bo.filetype]
  end,
})
