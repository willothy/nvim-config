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
    if vim.api.nvim_buf_get_name(bufnr) == "" then
      return false
    end
    return true
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
  willothy.ui.scrolleof.check()
  vim.schedule(function()
    if lazy_open then
      require("lazy.view").show()
      lazy_open = false
    end
  end)
end)

-- show an LSP progress indicator for session save
local progress = {}
---@diagnostic disable-next-line: redundant-parameter
resession.add_hook("pre_save", function(name)
  table.insert(
    progress,
    require("fidget.progress.handle").create({
      title = name,
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

  return require("types.trie").from_iter(resession.list()):matches(arg)
end

willothy.fn.create_command("Session", {
  desc = "Manage sessions",
  subcommands = {
    load = {
      complete = complete_session_name,
      execute = function(session)
        local ok = pcall(resession.load, session, {})
        if not ok then
          vim.notify("Unknown session: " .. session, "warn")
        end
      end,
    },
    delete = {
      complete = complete_session_name,
      execute = function(session)
        local ok = pcall(resession.delete, session)
        if not ok then
          vim.notify("Unknown session: " .. session, "warn")
        end
      end,
    },
    save = {
      complete = complete_session_name,
      execute = function(session)
        if not session then
          return resession.save_all({ notify = false })
        end
        resession.save(session)
      end,
    },
    list = {
      execute = function()
        resession.load(nil, {})
      end,
    },
  },
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
    {
      silence_errors = true,
      reset = true,
    }
  )
end

local uv = vim.uv or vim.loop

local SAVE_INTERVAL = 60000
local save_timer = uv.new_timer()
save_timer:start(
  SAVE_INTERVAL,
  SAVE_INTERVAL,
  vim.schedule_wrap(function()
    resession.save_all({ notify = false })
  end)
)

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
      local session = resession.get_current()
      if session then
        -- save all existing sessions
        resession.save_all({ notify = false })
      else
        -- ensure that there is a session for each tab
        for _, tabpage in ipairs(vim.api.nvim_list_tabpages()) do
          local win = vim.api.nvim_tabpage_get_win(tabpage)
          vim.api.nvim_win_call(win, function()
            local name = vim.fs.basename(vim.fn.getcwd(-1) --[[@as string]])
            resession.save_tab(name, { notify = false })
          end)
        end
      end
      if is_last then
        vim.cmd("qa!")
      end
    end
  end,
})
