vim.defer_fn(function()
  -- setup hydras
  willothy.hydras.__load_all()

  -- setup ui
  willothy.ui.__load_all()

  require("willothy.keymap")
  require("willothy.commands")
  require("willothy.autocmds")

  vim.api.nvim_exec_autocmds("User", { pattern = "ExtraLazy" })

  -- When lazy-loading this many plugins, auto-install can be janky.
  -- Therefore, I disable lazy's builtin auto-install and run it here.
  require("lazy.core.loader").install_missing()
end, 150)

-- Inform vim how to enable undercurl in wezterm
vim.api.nvim_exec2(
  [[
let &t_Cs = "\e[4:3m"
let &t_Ce = "\e[4:0m"
    ]],
  { output = false }
)
