local M = {}

--- Lazy-load hydras on body keys, and add the body as a group
--- in which-key. Also sets up the HydraEnter and HydraLeave user autocmds.
M.Hydra = function(config)
  local on_enter = function(f)
    return function(...)
      vim.api.nvim_exec_autocmds("User", {
        pattern = "HydraEnter",
      })
      if f then
        f(...)
      end
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
  local this
  if config.body and config.body ~= "" then
    local wk = require("which-key")
    vim.keymap.set(config.mode or "n", config.body, function()
      this:activate()
    end, { desc = "which_key_ignore" })
    wk.register({
      [config.body] = {
        name = (config.shortname or config.name):lower(),
        group = true,
        ["a"] = "which_key_ignore",
      },
    }, { mode = config.mode })
  end
  this = require("hydra")(config)
  this.config.stl_name = config.stl_name
  return this
end

return M
