local keymap = willothy.map
local bind, modes = keymap.bind, keymap.modes

local wk = require("which-key")

local function switch_by_step(step)
  local win = vim.api.nvim_get_current_win()

  if not require("stickybuf").is_pinned(win) then
    return require("cokeline.mappings").by_step("focus", step)
  end

  local buf = vim.api.nvim_win_get_buf(win)
  local ft = vim.bo[buf].filetype

  -- switch between buffers of a specific filetype
  local terminals = vim
    .iter(vim.api.nvim_list_bufs())
    :filter(function(t)
      return vim.bo[t].filetype == ft
    end)
    :enumerate()
    :fold({
      list = {},
      count = 0,
    }, function(acc, i, t)
      acc.list[i] = t
      acc.count = acc.count + 1
      if t == buf then
        acc.current = i
      end
      return acc
    end)

  local target = terminals.list[willothy.fn.clamp(
    1,
    terminals.count,
    terminals.current + step
  )]
  if target then
    vim.api.nvim_win_set_buf(win, target)
  end
end

local previous = {
  name = "previous",
  b = {
    function()
      switch_by_step(-vim.v.count1)
    end,
    "buffer",
  },
  t = bind(willothy.tab, "switch_by_step", -1):with_desc("tab"),
  e = bind("vim.diagnostic", "goto_prev", { severity = "error" }):with_desc(
    "error"
  ),
  m = bind("marks", "prev"):with_desc("mark"),
  d = bind("vim.diagnostic", "goto_prev"):with_desc("diagnostic"),
  ["["] = bind(function()
    require("harpoon"):list("files"):prev()
  end):with_desc("harpoon mark"),
}

local next = {
  name = "next",
  b = {
    function()
      switch_by_step(vim.v.count1)
    end,
    "buffer",
  },
  t = bind(willothy.tab, "switch_by_step", 1):with_desc("tab"),
  e = bind("vim.diagnostic", "goto_next", { severity = "error" }):with_desc(
    "error"
  ),
  m = bind("marks", "next"):with_desc("mark"),
  d = bind("vim.diagnostic", "goto_next"):with_desc("diagnostic"),
  ["]"] = bind(function()
    require("harpoon"):list("files"):next()
  end):with_desc("harpoon mark"),
}

wk.register(previous, { mode = modes.normal, prefix = "<leader>h" })
wk.register(previous, { mode = modes.normal, prefix = "[" })

wk.register(next, { mode = modes.normal, prefix = "<leader>l" })
wk.register(next, { mode = modes.normal, prefix = "]" })
