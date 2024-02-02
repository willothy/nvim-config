local focus = require("focus")

local ignore_filetypes = {
  ["oil"] = true,
  ["neo-tree"] = true,
  ["dap-repl"] = true,
  ["neotest-summary"] = true,
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

local function should_disable(buf, win)
  win = win or vim.fn.bufwinid(buf)
  if win and require("edgy").get_win(win) then
    return true
  else
    return ignore_filetypes[vim.bo[buf].filetype]
  end
end

vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    local buf = args.buf
    if should_disable(buf) then
      vim.b[buf].focus_disable = true
    else
      vim.b[buf].focus_disable = nil
    end
  end,
})

for _, win in ipairs(vim.api.nvim_list_wins()) do
  local buf = vim.api.nvim_win_get_buf(win)
  if
    vim.api.nvim_win_get_config(win).zindex == nil and should_disable(buf, win)
  then
    vim.b[buf].focus_disable = true
  end
end
vim.schedule(function()
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
end)
