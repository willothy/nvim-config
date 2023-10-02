local resession = require("resession")

resession.setup({
  extensions = {
    scope = {
      enable_in_tab = true,
    },
    overseer = {
      enable_in_tab = true,
    },
    aerial = {
      enable_in_tab = true,
    },
  },
  autosave = {
    enabled = true,
    interval = 60,
    notify = false,
  },
  tab_buf_filter = function(tabpage, bufnr)
    local cwd = vim.fn.getcwd(-1, vim.api.nvim_tabpage_get_number(tabpage))
    if not cwd then
      return true
    end
    return vim.startswith(vim.api.nvim_buf_get_name(bufnr), cwd)
  end,
  buf_filter = function(bufnr)
    local filetype = vim.bo[bufnr].filetype
    if
      filetype == "gitcommit"
      or filetype == "gitrebase"
      or vim.bo[bufnr].bufhidden == "wipe"
    then
      return false
    end
    local buftype = vim.bo[bufnr].buftype
    if buftype == "help" then
      return true
    end
    if buftype ~= "" and buftype ~= "acwrite" then
      return false
    end
    if vim.api.nvim_buf_get_name(bufnr) == "" then
      return false
    end
    return vim.bo[bufnr].buflisted
  end,
})

local lazy_open = false
willothy.event.on("ResessionLoadPre", function()
  local view = require("lazy.view")
  if view.view then
    lazy_open = true
    if view.view:buf_valid() then
      vim.api.nvim_buf_delete(view.view.buf, { force = true })
    end
    view.view:close({ wipe = true })
  else
    lazy_open = false
  end
end)

willothy.event.on(
  "ResessionLoadPost",
  vim.schedule_wrap(function()
    if lazy_open then
      require("lazy.view").show()
    end
  end)
)

vim.api.nvim_create_user_command("Session", function(args)
  args = args.fargs
  local command = args[1]
  if not command then
    vim.notify("No command specified", "warn")
    return
  end
  if command == "load" then
    if not args[2] then
      resession.load(nil, { dir = "dirsession" })
      return
    end
    local lookup = {}
    for _, session in ipairs(resession.list()) do
      local o = { name = session }
      lookup[session] = o
    end
    for _, session in ipairs(resession.list({ dir = "dirsession" })) do
      local name = session:gsub("_", "/")
      local o = { name = session, dir = "dirsession" }
      lookup[session] = o
    end
    if lookup[args[2]] then
      resession.load(lookup[args[2]].name, { dir = lookup[args[2]].dir })
    else
      vim.notify("Session not found: " .. args[2], "warn")
    end
  elseif command == "list" then
    resession.load(nil, { dir = "dirsession" })
  elseif command == "save" then
    resession.save_all({ notify = false })
  end
end, {
  nargs = "*",
  complete = function(arg, _line, pos)
    local list = {}
    if pos < 8 then
      return list
    end
    local options = {
      "load",
      "save",
      "list",
    }
    for _, option in ipairs(options) do
      if vim.startswith(option, arg) then
        table.insert(list, option)
      end
    end
    return list
  end,
})

-- show an LSP progress indicator for session save
local progress
willothy.event.on("ResessionSavePre", function()
  progress = willothy.utils.progress.create({
    title = "saving",
    message = "saving session",
    client_name = "resession",
  })
  progress:begin()
end)

willothy.event.on("ResessionSavePost", function()
  if progress then
    progress:finish({})
  end
  progress = nil
end)

if
  -- Only load the session if nvim was started with no args
  vim.fn.argc(-1) == 0
  -- Don't load in nested sessions
  and not require("flatten").is_guest()
  -- Don't load when running build scripts
  and vim.tbl_contains(vim.v.argv, "-l") == false
  -- Don't load if manually disabled
  and not vim.g.nosession
then
  resession.load(
    ---@diagnostic disable-next-line: param-type-mismatch
    vim.fs.basename(vim.fs.basename(vim.fn.getcwd())),
    { dir = "dirsession", silence_errors = true, reset = false }
  )
end

vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = vim.schedule_wrap(function()
    resession.save("last", { notify = false })
    vim.iter(vim.api.nvim_list_tabpages()):each(function(tab)
      local win = vim.api.nvim_tabpage_get_win(tab)
      vim.api.nvim_win_call(win, function()
        ---@diagnostic disable-next-line: param-type-mismatch
        local name = vim.fs.basename(vim.fn.getcwd(-1))
        resession.save_tab(name, { dir = "dirsession", notify = false })
      end)
    end)
    resession.save_all({ notify = false })
  end),
})
