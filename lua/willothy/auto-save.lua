---@field timers uv.uv_timer_t[]
local M = {}

M.timers = {}

function M.save(bufnr)
  M.progress_start("saving")
  if M.should_save(bufnr) == false then
    M.cancel(bufnr)
    M.progress_stop()
    return
  end

  M.callback("on_save", bufnr)
  vim.api.nvim_buf_call(
    bufnr,
    function() vim.api.nvim_exec2("silent! write", {}) end
  )
  M.callback("on_save_done", bufnr)
  M.progress_stop("saved")
end

function M.callback(id, bufnr)
  local f = M.config.callbacks[id]
  if f then return f(bufnr) end
end

function M.progress_start(title)
  M.send_progress({
    kind = "begin",
    title = title,
  })
end

function M.progress_stop(message)
  M.send_progress({
    kind = "end",
    title = message,
  })
end

function M.should_save(bufnr)
  for _, cond in ipairs(M.config.conditions) do
    if cond(bufnr) == false then return false end
  end
  return vim.api.nvim_buf_get_option(bufnr, "modified") == true
end

function M.immediate(bufnr)
  M.cancel(bufnr)
  if M.should_save(bufnr) then
    M.progress_start("saving")
    M.callback("on_immediate", bufnr)
    M.save(bufnr)
    M.callback("on_immediate_done", bufnr)
  end
end

function M.deferred(bufnr)
  M.cancel(bufnr)
  if M.should_save(bufnr) == true then
    local timer = vim.defer_fn(function()
      M.save(bufnr)
      M.callback("on_deferred_done", bufnr)
    end, 1000)
    M.timers[bufnr] = timer
    M.callback("on_deferred", bufnr)
  end
end

function M.cancel(bufnr)
  if M.timers[bufnr] then
    M.timers[bufnr]:stop()
    M.timers[bufnr] = nil
    M.callback("on_cancel", bufnr)
  end
end

function M.send_progress(data)
  if M.config.fancy_status then
    local handler = vim.lsp.handlers["$/progress"]
    if handler then
      handler(nil, {
        token = M.client,
        value = data,
      }, { client_id = M.client })
    end
  end
end

---@class AutoSave.Options
---@field condition (fun(bufnr: buffer, winnr: window): boolean)[]
---@field update { immediate: string[], deferred: string[], cancel: string[] }
---@field callbacks table<string, fun(bufnr: buffer)>

---@param opts AutoSave.Options
function M.setup(opts)
  opts = opts or {}

  opts = vim.tbl_deep_extend("keep", opts, {
    fancy_status = true,
    disable_format = true,
    events = {
      immediate = {
        "FocusLost",
        "BufLeave",
      },
      deferred = {
        "InsertLeave",
        "TextChanged",
      },
      cancel = "InsertEnter",
    },
    callbacks = {},
    conditions = {
      function(bufnr)
        return vim.api.nvim_buf_is_valid(bufnr)
          and vim.bo[bufnr].buftype == ""
          and vim.bo[bufnr].buflisted == true
        -- and vim.bo[bufnr].modifiable == true
        -- and vim.bo[bufnr].readonly == false
      end,
      -- function(bufnr)
      --   local ft = vim.bo[bufnr].filetype
      --   local ignore = {
      --     help = true,
      --     qf = true,
      --     gitcommit = true,
      --     gitrebase = true,
      --   }
      --   return ignore[ft] == nil
      -- end,
      function(bufnr) return vim.api.nvim_buf_get_name(bufnr) ~= "" end,
      function(bufnr)
        return vim.diagnostic.get(bufnr, { severity = 1 })[1] == nil
      end,
    },
  })

  vim.validate({
    ["fancy_status"] = { opts.fancy_status, "boolean", true },
    ["disable_format"] = { opts.disable_format, "boolean", true },
    ["events.immediate"] = {
      opts.events.immediate,
      { "table", "string" },
      true,
    },
    ["events.deferred"] = { opts.events.deferred, { "table", "string" } },
    ["events.cancel"] = { opts.events.cancel, { "table", "string" } },
    ["callbacks"] = { opts.callbacks, "table" },
    ["callbacks.on_immediate"] = {
      opts.callbacks.on_immediate,
      "function",
      true,
    },
    ["callbacks.on_immediate_done"] = {
      opts.callbacks.on_immediate_done,
      "function",
      true,
    },
    ["callbacks.on_deferred"] = { opts.callbacks.on_deferred, "function", true },
    ["callbacks.on_deferred_done"] = {
      opts.callbacks.on_deferred_done,
      "function",
      true,
    },
    ["callbacks.on_cancel"] = { opts.callbacks.on_cancel, "function", true },
    ["callbacks.on_save"] = { opts.callbacks.on_save, "function", true },
    ["callbacks.on_save_done"] = {
      opts.callbacks.on_save_done,
      "function",
      true,
    },
    ["conditions"] = {
      opts.conditions,
      function(c)
        if type(c) ~= "table" then
          return false, ("expected table, found %s"):format(type(c))
        end

        for _, cond in ipairs(c) do
          if type(cond) ~= "function" then
            return false, ("invalid callback: %s"):format(cond)
          end
        end
        return true
      end,
      "table",
    },
  })

  M.config = opts

  if M.config.fancy_status then
    M.client = vim.lsp.start({
      name = "auto-save",
      cmd = function()
        return {
          request = function() end,
        }
      end,
      filetypes = { "lua" },
    })
  end

  M.send_progress({
    kind = "begin",
    title = "initializing",
  })

  if M.config.disable_format then
    local prev_save
    if M.config.callbacks.on_save then
      prev_save = M.config.callbacks.on_save
    end
    M.config.callbacks.on_save = function(bufnr)
      require("lsp-format").disable({ args = "" })
      if prev_save then prev_save(bufnr) end
    end
    local prev_save_done
    if M.on_save_done then prev_save_done = M.config.callbacks.on_save_done end
    M.config.callbacks.on_save_done = function(bufnr)
      require("lsp-format").enable({ args = "" })
      if prev_save_done then prev_save_done(bufnr) end
    end
  end

  local au = vim.api.nvim_create_augroup("auto-save", { clear = true })
  vim.api.nvim_create_autocmd(M.config.events.immediate, {
    group = au,
    callback = function()
      local buf = vim.api.nvim_get_current_buf()
      M.immediate(buf)
    end,
  })

  vim.api.nvim_create_autocmd(M.config.events.deferred, {
    group = au,
    callback = function()
      local buf = vim.api.nvim_get_current_buf()
      return M.deferred(buf)
    end,
  })

  vim.api.nvim_create_autocmd(M.config.events.cancel, {
    group = au,
    callback = function(ev)
      local buf = ev.buf or vim.api.nvim_get_current_buf()
      M.cancel(buf)
    end,
  })

  M.send_progress({
    kind = "end",
    title = "ready",
    message = "ready",
  })
end

return {
  setup = M.setup,
}
