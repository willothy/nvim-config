vim.defer_fn(function()
  vim.api.nvim_exec_autocmds("User", { pattern = "ExtraLazy" })

  setmetatable(
    willothy.hydras,
    willothy.ns({
      git = true,
      options = true,
      telescope = true,
      diagrams = true,
      windows = true,
      buffers = true,
      swap = true,
    }, "hydras")
  )

  -- setup hydras
  willothy.hydras.__load_all()

  -- setup mappings
  require("willothy.keymap")

  -- setup commands
  require("willothy.commands")
end, 150)

-- Inform vim how to enable undercurl in wezterm
vim.api.nvim_exec2(
  [[
let &t_Cs = "\e[4:3m"
let &t_Ce = "\e[4:0m"
    ]],
  { output = false }
)
