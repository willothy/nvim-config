require("wf").setup({})

local which_key = require("wf.builtin.which_key")

local leaders = {
  ["<leader>"] = "<Space>",
  ["<C-w>"] = "<C-W>",
  g = "g",
  z = "z",
}

for leader, map in pairs(leaders) do
  vim.keymap.set("n", leader, which_key({ text_insert_in_advance = map }), {
    noremap = true,
    silent = true,
    desc = "[wf.nvim] which-key /",
    nowait = true,
  })
end
