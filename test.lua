-- Minimal configuration
-- mini.lua
-- Use with the --clean -u flags. EG nvim --clean -u mini.lua
-- This config will create a temp directory and will blow away that temp directory
-- everytime this configuration is loaded. Great for simulating a new installation
-- of a plugin

-- Setting some basic vim options
-- Some junk because I am sick of formatting tables in print
local _print = _G.print
local clean_string = function(...)
  local args = { n = select("#", ...), ... }
  local formatted_args = {}
  for i = 1, args.n do
    local item = select(i, ...)
    if not item then item = "nil" end
    local t_type = type(item)
    if t_type == "table" or t_type == "function" or t_type == "userdata" then
      item = vim.inspect(item)
    end
    table.insert(formatted_args, item)
  end
  return table.concat(formatted_args, " ")
end
_G.print = function(...)
  _print(clean_string(...))
end

vim.opt.mouse = "a"
vim.opt.termguicolors = true
-- If you want to play around with this, you can set the do_clean
-- variable to false. This will allow changes made to
-- underlying plugins to persist between sessions, while
-- still keeping everything in its own directory so
-- as to not affect your existing neovim installation.
--
-- Setting this to true will result in a fresh clone of
-- all modules
local do_clean = true

local sep = vim.loop.os_uname().sysname:lower():match("windows") and "\\" or "/" -- \ for windows, mac and linux both use \

local mod_path =
  string.format("%s%sclean-test%s", vim.fn.stdpath("cache"), sep, sep)
if vim.loop.fs_stat(mod_path) and do_clean then
  print("Found previous clean test setup. Cleaning it out")
  -- Clearing out the mods directory and recreating it so
  -- you have a fresh run everytime
  vim.fn.delete(mod_path, "rf")
end

vim.fn.mkdir(mod_path, "p")

local modules = {
  { "nvim-lua/plenary.nvim" },
  { "nvim-tree/nvim-web-devicons" },
  { "willothy/nvim-cokeline", mod = "cokeline", branch="hl-refactor" },
}

for _, module in ipairs(modules) do
  local repo = module[1]
  local branch = module.branch
  local module_name = repo:match("/(.*)")
  local module_path = string.format("%s%s%s", mod_path, sep, module_name)
  if not vim.loop.fs_stat(module_name) then
    -- The module doesn't exist, download it
    local cmd = {
      "git",
      "clone",
    }
    if branch then
      table.insert(cmd, "--branch")
      table.insert(cmd, branch)
    end
    table.insert(cmd, string.format("https://github.com/%s", repo))
    table.insert(cmd, module_path)
    vim.fn.system(cmd)
    local message = string.format("Downloaded %s", module_name)
    if branch then
      message = string.format("%s on branch %s", message, branch)
    end
    print(message)
  end
  vim.opt.runtimepath:append(module_path)
end

print("Finished installing plugins. Beginning Setup of plugins")

for _, module in ipairs(modules) do
  if module.mod then
    print(string.format("Loading %s", module.mod))
    local success, err = pcall(require, module.mod)
    if not success then
      print(string.format("Failed to load module %s", module.mod))
      error(err)
    end
  end
end

-- --> Do you module setups below this line <-- --
vim.api.nvim_set_hl(0, "BufferLineFill", { fg = "NONE", bg = "NONE" })
require("cokeline").setup({
  fill_hl = "BufferLineFill",
  default_hl = {
    fg = "NONE",
    bg = "NONE",
  },
  components = {
    {
      text = function(buffer)
        return buffer.is_focused and "x" or " "
      end,
      fg = "NONE",
      bg = "NONE",
    },
    {
      text = function(buffer)
        return buffer.filename .. " "
      end,
      style = function(buffer)
        if buffer.is_hovered and not buffer.is_focused then
          return "underline"
        end
      end,
    },
  },
})
-- --> Do your module setups above this line <-- --

print("Completed minimal setup!")
