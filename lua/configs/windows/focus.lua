local focus = require("focus")

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
    ignore_filetypes = {
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
    },
  },
})
