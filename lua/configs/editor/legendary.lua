require("telescope").load_extension("ui-select")
require("legendary").setup({
  funcs = {},
  autocmds = {},
  commands = {},
  keymaps = {},
  which_key = {
    auto_register = true,
  },
  lazy_nvim = {
    auto_register = true,
  },
  extensions = {
    nvim_tree = false,
    op_nvim = false,
    smart_splits = true,
    diffview = true,
  },
})
