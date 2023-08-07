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

local util = require("willothy.util.keymap")
local modes = util.modes
local group = util.group

group(modes.non_editing, "j", "jump")
group(modes.non_editing, "g", "git")
group(modes.non_editing, "t", "terminal")
group(modes.non_editing, "tr", "repl")
--group(modes.non_editing, "b", "buffer")
group(modes.non_editing, "p", "projects")
group(modes.non_editing, "c", "lsp")
-- group(modes.non_editing, "v", "view")
-- group(modes.non_editing, "vL", "legendary")
-- group(modes.non_editing, "m", "marks")
-- group(modes.non_editing, "[", "previous", true)
-- group(modes.non_editing, "]", "next", true)
