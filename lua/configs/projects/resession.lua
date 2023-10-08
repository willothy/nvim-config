local resession = require("resession")

resession.setup({
  extensions = {
    cokeline = {
      enable_in_tab = true,
    },
    edgy = {
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

resession.add_hook("pre_load", function()
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

resession.add_hook("post_load", function()
  vim.o.showtabline = 2
  vim.schedule(function()
    if lazy_open then
      require("lazy.view").show()
      lazy_open = false
    end
  end)
end)

-- show an LSP progress indicator for session save
local progress
---@diagnostic disable-next-line: redundant-parameter
resession.add_hook("pre_save", function(name)
  progress = willothy.utils.progress.create({
    title = "saving " .. name,
    message = "saving session",
    client_name = "resession",
  })
  progress:begin()
end)

resession.add_hook(
  "post_save",
  vim.schedule_wrap(function()
    if progress then
      progress:finish({})
      progress = nil
    end
  end)
)

local commands = {
  load = function(session)
    local ok = pcall(resession.load, session, {})
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
    resession.load(nil, {})
  end,
  save = function(session)
    if not session then
      return resession.save_all({ notify = false })
    end
    resession.save(session)
  end,
}

local function complete(arg, line)
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
end

local function execute(args)
  args = args.fargs
  local command = args[1]
  if not command then
    vim.notify("No command specified", vim.log.levels.WARN)
  elseif commands[command] then
    commands[command](unpack(args, 2))
  else
    vim.notify("Unknown command: " .. command, vim.log.levels.WARN)
  end
end

vim.api.nvim_create_user_command("Session", execute, {
  nargs = "*",
  desc = "Manage sessions",
  complete = complete,
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
    vim.fs.basename(vim.fn.getcwd()),
    { silence_errors = true, reset = true }
  )
end

vim.api.nvim_create_autocmd("QuitPre", {
  group = vim.api.nvim_create_augroup("ResessionAutosave", { clear = true }),
  callback = function()
    local curwin = vim.api.nvim_get_current_win()
    local wins = vim.api.nvim_list_wins()
    local has_normal = false
    local is_last = true

    for i = 1, #wins do
      local win = wins[i]
      if
        vim.api.nvim_win_get_config(win).zindex == nil
        and require("edgy").get_win(win) == nil
      then
        has_normal = true
        if win ~= curwin then
          is_last = false
          break
        end
      end
    end
    if has_normal then
      local name = vim.fs.basename(vim.fn.getcwd(-1) --[[@as string]])
      resession.save_tab(name, { notify = false })
      if is_last then
        vim.cmd("qa!")
      end
    end
  end,
})
