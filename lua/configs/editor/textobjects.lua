-- nvim-treesitter-textobjects `main`: keymaps are no longer declared in the
-- setup table; they're plain vim.keymap.set calls into the select/move modules.
-- Migrated from the old textobjects block in willothy/treesitter.lua.
require("nvim-treesitter-textobjects").setup({
  select = {
    lookahead = true,
    selection_modes = {
      ["@parameter.outer"] = "v",
      -- ["@function.outer"] = "V",
      ["@class.outer"] = "<c-v>",
    },
  },
  move = {
    set_jumps = true,
  },
})

local select = require("nvim-treesitter-textobjects.select")
local move = require("nvim-treesitter-textobjects.move")

---@param query string
local function sel(query)
  return function()
    select.select_textobject(query, "textobjects")
  end
end

---@param fn fun(query: string, group: string)
---@param query string
local function goto_(fn, query)
  return function()
    fn(query, "textobjects")
  end
end

-- select
local selects = {
  ["is"] = { "@statement.inner", "statement" },
  ["as"] = { "@statement.outer", "statement" },
  ["ic"] = { "@class.inner", "class" },
  ["ac"] = { "@class.outer", "class" },
  ["iF"] = { "@function.inner", "function" },
  ["aF"] = { "@function.outer", "function" },
}
for lhs, spec in pairs(selects) do
  vim.keymap.set({ "x", "o" }, lhs, sel(spec[1]), { desc = spec[2] })
end

-- move
vim.keymap.set(
  { "n", "x", "o" },
  "]f",
  goto_(move.goto_next_start, "@function.outer"),
  { desc = "function" }
)
vim.keymap.set(
  { "n", "x", "o" },
  "]c",
  goto_(move.goto_next_start, "@call.outer"),
  { desc = "call" }
)
vim.keymap.set(
  { "n", "x", "o" },
  "[f",
  goto_(move.goto_previous_start, "@function.outer"),
  { desc = "function" }
)
vim.keymap.set(
  { "n", "x", "o" },
  "[c",
  goto_(move.goto_previous_start, "@call.outer"),
  { desc = "call" }
)
