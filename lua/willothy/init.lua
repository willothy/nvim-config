local ns = function(modules, submodule)
  vim.tbl_add_reverse_lookup(modules)
  if submodule then
    submodule = submodule .. "."
  else
    submodule = ""
  end
  return {
    __index = function(self, k)
      if modules[k] then
        local mod = require("willothy.modules." .. submodule .. k)
        if mod.setup then
          mod.setup()
        end
        rawset(self, k, mod)
        return mod
      elseif k == "__load_all" then
        for _, mod in ipairs(modules) do
          mod = require("willothy.modules." .. submodule .. mod)
          if type(mod) == "table" and mod.setup then
            mod.setup()
          end
        end
        return function() end
      else
        error("module " .. k .. " not found")
      end
    end,
    __newindex = function(_, k)
      error("cannot write to willothy." .. k)
    end,
  }
end

willothy = {}
willothy.utils = {}
willothy.hydras = {}

setmetatable(
  willothy,
  ns({
    "fs",
    "hl",
    "fn",
    "icons",
    "keymap",
    "player",
    "term",
    "scrollbar",
    "terminals",
    -- "floats"
  })
)

setmetatable(
  willothy.utils,
  ns({
    "cursor",
    "window",
    "tabpage",
    "mode",
    "plugins",
    "debug",
  }, "utils")
)

setmetatable(
  willothy.hydras,
  ns({
    "git",
    "options",
    "telescope",
    "diagrams",
    "windows",
    "buffers",
    "swap",
  }, "hydras")
)

require("willothy.settings")

willothy.fs.hijack_netrw()

vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  once = true,
  callback = vim.schedule_wrap(function()
    vim.defer_fn(function()
      vim.api.nvim_exec_autocmds("User", { pattern = "ExtraLazy" })
    end, 150)

    -- Inform vim how to enable undercurl in wezterm
    vim.api.nvim_exec2(
      [[
let &t_Cs = "\e[4:3m"
let &t_Ce = "\e[4:0m"
    ]],
      { output = false }
    )
  end),
})

vim.api.nvim_create_autocmd("User", {
  pattern = "ExtraLazy",
  once = true,
  callback = function()
    -- setup hydras
    willothy.hydras.__load_all()

    -- setup mappings
    require("willothy.keymap")

    -- setup commands
    require("willothy.commands")
  end,
})
