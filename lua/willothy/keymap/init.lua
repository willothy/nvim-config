-- remove all mouse mappings
local disable = {
  -- "<2-LeftMouse>",
  "<3-LeftMouse>",
  "<4-LeftMouse>",
  "<RightMouse>",
  "<2-RightMouse>",
  "<3-RightMouse>",
  "<4-RightMouse>",
}

for _, v in ipairs(disable) do
  vim.keymap.set({ "n", "v", "i" }, v, "<Nop>", { silent = true })
end

require("willothy.keymap.normal")
require("willothy.keymap.window")
require("willothy.keymap.editor")
require("willothy.keymap.terminal")
require("willothy.keymap.cycle")
require("willothy.keymap.view")
require("willothy.keymap.git")
require("willothy.keymap.buffer")
require("willothy.keymap.projects")
require("willothy.keymap.lsp")
require("willothy.keymap.jump")