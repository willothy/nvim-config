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
  if config.body and config.body ~= "" then
    vim.keymap.set(config.mode, config.body, function()
      if this == nil then
        config.body = nil
        if hintfunc then
          config.hint = hintfunc(config)
        end
        this = require("hydra")(config)
      end
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
    local ready = false
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

function M.setup()
  require("willothy.hydras.git")
  require("willothy.hydras.options")
  require("willothy.hydras.telescope")
  require("willothy.hydras.diagrams")
  require("willothy.hydras.windows")
  require("willothy.hydras.buffers")

  vim.api.nvim_set_hl(0, "HydraBorder", { link = "CursorLineNr" })
  -- vim.api.nvim_set_hl(0, "HydraBorder", { link = "WhichKeyBorder" })
end

return M
