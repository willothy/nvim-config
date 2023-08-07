-- remove all mouse mappings
local disable = {
  "<2-LeftMouse>",
  "<3-LeftMouse>",
  "<4-LeftMouse>",
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
require("willothy.keymap.toggle")
require("willothy.keymap.buffer")
require("willothy.keymap.files")
require("willothy.keymap.lsp")
require("willothy.keymap.jump")

if not pcall(require, "which-key") then return end

require("which-key").register({
  v = {
    name = "view",
    L = {
      name = "legendary",
    },
  },
  m = { name = "marks" },
  g = {
    name = "git",
  },
  t = {
    name = "terminal",
    r = {
      name = "repl",
    },
  },
  b = {
    name = "buffer",
  },
  p = {
    name = "project",
  },
  c = {
    name = "lsp",
  },
  j = {
    name = "jump",
  },
}, { prefix = "<leader>" })
