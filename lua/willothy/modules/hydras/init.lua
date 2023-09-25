local M = {}

--- Lazy-load hydras on body keys, and add the body as a group
--- in which-key
M.Hydra = function(hintfunc, config)
  if config == nil and type(hintfunc) == "table" then
    config = hintfunc
    hintfunc = nil
  end
  local this

  local on_enter = function(f)
    return function(...)
      if f then
        f(...)
      end
      vim.api.nvim_exec_autocmds("User", {
        pattern = "HydraEnter",
      })
    end
  end
  local on_exit = function(f)
    return function(...)
      if f then
        f(...)
      end
      vim.api.nvim_exec_autocmds("User", {
        pattern = "HydraLeave",
      })
    end
  end
  config.config.on_exit = on_exit(config.config.on_exit)
  config.config.on_enter = on_enter(config.config.on_enter)
  local ready = false
  if config.body and config.body ~= "" then
    vim.keymap.set(config.mode, config.body, function()
      config.body = nil
      if hintfunc and config.hint == nil then
        config.hint = hintfunc(config)
      end
      this = require("hydra")(config)
      this:activate()
    end)
    local ok, wk = pcall(require, "which-key")
    if ok then
      wk.register({
        [config.body] = {
          name = (config.shortname or config.name):lower(),
          group = true,
          ["a"] = "which_key_ignore",
        },
      }, {})
    end
  else
  end
  if type(this) ~= "table" then
    this = setmetatable({}, {
      __index = function(_, k)
        if not ready then
          ready = true
          this = require("hydra")(config)
          if k == "activate" then
            this:activate()
            return function() end
          end
        end
        return this[k]
      end,
    })
  end
  return this
end

return M
