local bar = require("willothy.ui.icons").git.signs.bar

local gitsigns = require("gitsigns")

local git = require("gitsigns.git")
local _set_version = git._set_version
git._set_version = function(version)
  pcall(_set_version, version)
end

local function do_setup()
  gitsigns.setup({
    signs = {
      untracked = { text = bar },
      add = { text = bar },
      change = { text = bar },
      delete = { text = bar },
      topdelete = { text = bar },
      changedelete = { text = bar },
    },
    preview_config = {
      focusable = false,
      -- Options passed to nvim_open_win
      border = "single",
      style = "minimal",
      relative = "cursor",
      row = 0,
      col = 1,
    },
    trouble = true,
    signcolumn = true,
    update_debounce = 250,
    -- _extmark_signs = false,
    -- on_attach = vim.schedule_wrap(function(bufnr)
    --   vim.cmd.GitConflictRefresh()
    -- end),
  })
end

if vim.g.did_very_lazy ~= nil then
  vim.schedule(do_setup)
else
  vim.api.nvim_create_autocmd("User", {
    pattern = "VeryLazy",
    once = true,
    callback = vim.schedule_wrap(do_setup),
  })
end
