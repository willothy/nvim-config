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
    -- aerial = {
    --   enable_in_tab = true,
    -- },
    oil = {
      enable_in_tab = true,
    },
    scope = {},
  },
  autosave = {
    enabled = false,
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
    if
      vim.api.nvim_buf_get_name(bufnr) == ""
      or not vim.api.nvim_buf_is_loaded(bufnr)
    then
      return false
    end
    return true
  end,
})

local lazy_open = false

resession.add_hook("pre_load", function()
  require("edgy.config").animate.enabled = false
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
  vim.schedule(function()
    require("edgy.config").animate.enabled = true
  end)

  vim.schedule(function()
    vim
      .iter(vim.api.nvim_list_wins())
      :map(function(win)
        ---@diagnostic disable-next-line: redundant-return-value
        return win, vim.api.nvim_win_get_buf(win)
      end)
      :filter(function(_, buf)
        return vim.bo[buf].filetype == "oil"
      end)
      :each(function(win, buf)
        vim.api.nvim_win_call(win, function()
          require("oil").open(vim.api.nvim_buf_get_name(buf))
        end)
      end)
    require("willothy.ui.scrolleof").check()
    -- Fixes lazy freaking out when a session is loaded and there are
    -- auto-installs being run.
    if lazy_open then
      require("lazy.view").show()
      lazy_open = false
    end

    local function do_bufread()
      vim.api.nvim_exec_autocmds("BufReadPost", {
        buffer = vim.api.nvim_get_current_buf(),
      })
    end

    if vim.g.did_very_lazy then
      do_bufread()
    else
      vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        once = true,
        callback = vim.schedule_wrap(do_bufread),
      })
    end
  end)
end)

-- show an LSP progress indicator for session save
local progress = {}
---@diagnostic disable-next-line: redundant-parameter
resession.add_hook("pre_save", function(name)
  local util = require("resession.util")
  local filename = util.get_session_file(name)
  local info = require("resession.files").load_json_file(filename)

  local title
  if info then
    if info.tab_scoped then
      title = info.tabs[1].cwd
    else
      title = info.global.cwd
    end
    title = vim.fs.basename(title) or title
  else
    title = name
  end
  table.insert(
    progress,
    require("fidget.progress.handle").create({
      title = title,
      message = "saving session",
      lsp_client = {
        name = "resession",
      },
    })
  )
end)

resession.add_hook(
  "post_save",
  vim.schedule_wrap(function()
    local p = table.remove(progress, 1)
    if p then
      vim.defer_fn(function()
        p:finish()
      end, 1000)
    end
  end)
)

local function complete_session_name(arg, line)
  local obj = vim.api.nvim_parse_cmd(line, {})
  if #obj.args > 1 then
    return {}
  end

  -- Extra completion filtering with tries because why not
  return require("willothy.lib.trie").from_iter(resession.list()):matches(arg)
end

-- Session management commands
require("willothy.lib.fn").create_command("Session", {
  desc = "Manage sessions",
  command = function()
    vim.cmd.Session("load")
  end,
  subcommands = {
    load = {
      complete = complete_session_name,
      execute = function(session)
        session = session and vim.trim(session)
        if session == nil or session == "" then
          vim.cmd.Session("list")
          return
        end
        local ok = pcall(resession.load, session, {})
        if not ok then
          vim.notify("Unknown session: " .. session, vim.log.levels.WARN)
        end
      end,
    },
    delete = {
      complete = complete_session_name,
      execute = function(session)
        session = session and vim.trim(session)
        local ok = pcall(resession.delete, session)
        if not ok then
          vim.notify("Unknown session: " .. session, vim.log.levels.WARN)
        end
      end,
    },
    save = {
      complete = complete_session_name,
      execute = function(session)
        session = session and vim.trim(session)
        if session == nil or session == "" then
          return resession.save_all({ notify = false })
        end
        resession.save(session)
      end,
    },
    list = {
      execute = function()
        local sessions = resession.list({})
        if vim.tbl_isempty(sessions) then
          vim.notify("No saved sessions", vim.log.levels.WARN)
          return
        end
        local select_opts =
          { kind = "resession_load", prompt = "Load session" }
        local session_data = {}
        local util = require("resession.util")
        local shortnames = {}
        for _, session_name in ipairs(sessions) do
          local filename = util.get_session_file(session_name)
          local data = require("resession.files").load_json_file(filename)
          session_data[session_name] = data
        end
        for name, data in pairs(session_data) do
          local cwd
          if data.tab_scoped then
            cwd = data.tabs[1].cwd
          else
            cwd = data.global.cwd
          end
          local shortname = vim.fs.basename(cwd) or name
          if shortnames[shortname] then
            local other = shortnames[shortname]
            local other_cwd
            if other.tab_scoped then
              other_cwd = other.tabs[1].cwd
            else
              other_cwd = other.global.cwd
            end
            local new_other = vim.fs.basename(
              vim.fs.dirname(other_cwd:gsub("/$", ""))
                or other_cwd:gsub("/$", "")
            ) .. "/" .. shortname
            local new_short = vim.fs.basename(
              vim.fs.dirname(cwd):gsub("/$", "") or cwd:gsub("/$", "")
            ) .. "/" .. shortname

            data.short_name = new_short
            other.short_name = new_other

            shortnames[new_short] = data
            shortnames[new_other] = other
          else
            shortnames[shortname] = data
            data.short_name = shortname
          end
        end
        select_opts.format_item = function(session_name)
          local data = session_data[session_name]
          if data then
            if data.tab_scoped then
              local tab_cwd = data.tabs[1].cwd
              return string.format(
                "%s (tab) [%s]",
                data.short_name,
                util.shorten_path(tab_cwd)
              )
            else
              return string.format(
                "%s [%s]",
                data.short_name,
                util.shorten_path(data.global.cwd)
              )
            end
          end
          return session_name
        end
        vim.ui.select(sessions, select_opts, function(selected)
          if selected then
            resession.load(selected, {})
          end
        end)
      end,
    },
  },
})

local function is_empty()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if
      vim.bo[buf].buftype == ""
      and vim.bo[buf].buflisted
      and vim.api.nvim_buf_get_name(buf) ~= ""
    then
      return false
    end
  end
  local n_splits = 0
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_config(win).zindex == nil then
      n_splits = n_splits + 1
      if n_splits > 1 then
        return false
      end
    end
  end
  return true
end

local argc = vim.fn.argc(-1)

if
  -- Only load the session if nvim was started with no args
  argc == 0
  -- Don't load when running build scripts
  and vim.tbl_contains(vim.v.argv, "-l") == false
  -- Don't load if manually disabled
  and not vim.g.nosession
  -- Don't load in nested sessions
  and not require("flatten").is_guest()
then
  resession.load(vim.fn.getcwd():gsub("/", "_"), {
    silence_errors = true,
    reset = true,
  })
  vim.schedule(function()
    if is_empty() then
      require("willothy.ui.intro").show()
    end
  end)
elseif argc == 0 and is_empty() then
  require("willothy.ui.intro").show()
end

local uv = vim.uv or vim.loop

-- autosave once per minute
local SAVE_INTERVAL = 60000
local save_timer = assert(uv.new_timer())
save_timer:start(
  SAVE_INTERVAL,
  SAVE_INTERVAL,
  vim.schedule_wrap(function()
    -- only save if there are non-gitcommit buffers
    -- so that running `git commit` from cmdline outside of nvim
    -- and opening the commit message in editor doesn't overwrite
    -- the project's session.
    local only_commit = true
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if
        vim.bo[buf].buftype == ""
        and vim.bo[buf].buflisted
        and vim.bo[buf].filetype ~= "gitcommit"
      then
        only_commit = false
        break
      end
    end
    if not only_commit then
      resession.save_all({ notify = false })
    end
  end)
)

-- Cursed QuitPre autocmd that saves the session before closing windows containing
-- non-normal buffers, so that the main layout is properly saved.
local group =
  vim.api.nvim_create_augroup("willothy/ResessionAutosave", { clear = true })
local quitting = false
vim.api.nvim_create_autocmd("QuitPre", {
  group = group,
  nested = true,
  callback = function()
    if quitting then
      return
    end

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
      -- don't save a session if it's just a git commit so that
      -- running `git commit` from cmdline outside of nvim and
      -- opening the commit message in editor doesn't overwrite
      -- the project's session.
      -- I should refactor this though it's a mess
      local only_commit = true -- FIXME: why did I use two variables?
      local nothing_else = true
      for buf in
        vim.iter(vim.api.nvim_list_bufs()):filter(function(buf)
          return vim.bo[buf].buftype == "" and vim.bo[buf].buflisted
        end)
      do
        nothing_else = false
        local ft = vim.bo[buf].filetype
        if ft ~= "gitcommit" and ft ~= "gitrebase" then
          only_commit = false
          break
        end
      end
      only_commit = only_commit and not nothing_else
      if not only_commit then
        local session = resession.get_current()
        if session then
          -- save all existing sessions
          resession.save_all({ notify = false })
        else
          -- ensure that there is a session for each tab
          for _, tabpage in ipairs(vim.api.nvim_list_tabpages()) do
            local win = vim.api.nvim_tabpage_get_win(tabpage)
            vim.api.nvim_win_call(win, function()
              local name = vim.fn.getcwd(-1) --[[@as string]]
              resession.save_tab(name, { notify = false })
            end)
          end
        end
      end
      if is_last then
        -- vim.o.confirm = true -- ensures that we are prompted to save
        quitting = true
        vim.cmd.quitall()
      end
    end
  end,
})
