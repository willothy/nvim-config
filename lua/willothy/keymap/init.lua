-- remove all mouse mappings
local disable = {
  -- "<2-LeftMouse>",
  -- "<LeftDrag>",
  -- "<LeftRelease>",
  "<3-LeftMouse>",
  "<4-LeftMouse>",
  "<RightMouse>",
  "<2-RightMouse>",
  "<3-RightMouse>",
  "<4-RightMouse>",
}

for _, v in ipairs(disable) do
  vim.keymap.set(
    { "n", "v", "i" },
    v,
    function() end,
    { expr = true, desc = "which_key_ignore" }
  )
end

require("willothy.keymap.window")
require("willothy.keymap.terminal")
require("willothy.keymap.cycle")
require("willothy.keymap.view")
require("willothy.keymap.find")
require("willothy.keymap.git")
require("willothy.keymap.buffer")
require("willothy.keymap.projects")
require("willothy.keymap.lsp")
require("willothy.keymap.jump")
require("willothy.keymap.editor")
