require("willothy.settings")

local function initialize()
  -- setup hydras
  require("willothy.hydras")

  vim.defer_fn(function()
    vim.api.nvim_exec_autocmds("User", { pattern = "ExtraLazy" })
  end, 100)
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

    -- require("wf").setup({})
    -- if not _G.__key_prefixes then _G.__key_prefixes = {} end
    -- _G.__key_prefixes["n"]["<leader>p"] = "+projects"

    -- setup annoying "use hjkl" messages
    -- require("willothy.hjkl")()
  end,
})

-- setup float dragging
-- require("willothy.ui").setup({
--   resize = "<S-LeftDrag>",
-- })

-- Hacky way of detaching UI
-- vim.api.nvim_create_user_command("Detach", function()
--   local uis = vim.api.nvim_list_uis()
--   if #uis < 1 then return end
--   local chan = uis[1].chan
--   vim.fn.chanclose(chan)
-- end, {})
