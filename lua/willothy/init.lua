require("willothy.settings")

local function initialize()
  -- setup hydras
  require("willothy.hydras").setup()

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
end

vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  once = true,
  callback = vim.schedule_wrap(function()
    initialize()
  end),
})

vim.api.nvim_create_autocmd("User", {
  pattern = "ExtraLazy",
  once = true,
  callback = function()
    -- setup mappings
    require("willothy.keymap")

    -- setup commands
    require("willothy.commands")

    -- setup float dragging and modenr
    require("willothy.ui").setup()

    require("willothy.util.fs").hijack_netrw()
  end,
})
