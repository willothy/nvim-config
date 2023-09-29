local M = {}

M.sidebar = {
  side = "left",
  -- open = vim.o.columns >= 150, --vim.fn.argc() ~= 0,
  open = false,
  section_separator = { " ", " " },
  sections = {
    -- "git",
    "datetime",
    "files",
    -- "symbols",
    -- "diagnostics",
    -- "todos",
    "containers",
  },
}

M.neotree = {
  source_selector = {
    winbar = false,
  },
  sources = {
    "filesystem",
    "buffers",
    "git_status",
    "diagnostics",
  },
  filesystem = {
    hijack_netrw_behavior = "disabled",
  },
}

M.aerial = {
  layout = {
    default_direction = "left",
    placement = "edge",
  },
  attach_mode = "global",
}

return M
