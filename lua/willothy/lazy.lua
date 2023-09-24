return {
  setup = function()
    -- setup hydras
    willothy.hydras.__load_all()

    -- setup ui
    willothy.ui.__load_all()

    require("willothy.commands")
    require("willothy.autocmds")
    require("willothy.keymap")

    ---@diagnostic disable-next-line: duplicate-set-field
    -- vim.ui.select = function(...)
    --   require("telescope").load_extension("ui-select")
    --   vim.ui.select(...)
    -- end

    vim.api.nvim_exec_autocmds("User", { pattern = "ExtraLazy" })

    -- Inform vim how to enable undercurl in wezterm
    vim.api.nvim_exec2(
      [[
let &t_Cs = "\e[4:3m"
let &t_Ce = "\e[4:0m"
    ]],
      { output = false }
    )
  end,
}
