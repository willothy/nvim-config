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

local commands = {
  load = function(session)
    local ok = pcall(resession.load, session)
    if not ok then
      vim.notify("Unknown session: " .. session, "warn")
    end
  end,
  delete = function(session)
    local ok = pcall(resession.delete, session)
    if not ok then
      vim.notify("Unknown session: " .. session, "warn")
    end
  end,
  list = function()
    resession.load(nil)
  end,
  save = function(session)
    if not session then
      return resession.save_all({ notify = false })
    end
    resession.save(session)
  end,
}

vim.api.nvim_create_user_command("Session", function(args)
  args = args.fargs
  local command = args[1]
  if not command then
    vim.notify("No command specified", "warn")
  elseif commands[command] then
    commands[command](unpack(args, 2))
  else
    vim.notify("Unknown command: " .. command, "warn")
    return
  end
end, {
  nargs = "*",
  desc = "Manage sessions",
  complete = function(arg, line)
    local res = vim.api.nvim_parse_cmd(line, {})
    local argc = #res.args
    local first = false
    if argc == 0 then
      first = true
    end
    if argc == 1 and not line:match("%s$") then
      first = true
    end
    if first then
      return vim
        .iter(commands)
        :filter(function(option)
          return vim.startswith(option, arg)
        end)
        :map(function(name)
          return name
        end)
        :totable()
    elseif argc == 2 or (argc == 1 and line:match("%s$")) then
      if res.args[1] == "load" or res.args[1] == "delete" then
        return vim
          .iter(resession.list())
          :filter(function(session)
            return vim.startswith(session, arg)
          end)
          :map(function(session)
            return session
          end)
          :totable()
      end
    end
  end,
})

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
    { silence_errors = true, reset = false }
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
        resession.save_tab(name, { notify = false })
      end)
    end)
    resession.save_all({ notify = false })
  end),
})
