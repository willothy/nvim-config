local keymap = willothy.keymap
local modes = keymap.modes

local neogit = setmetatable({}, {
  __index = function(_, popup)
    return {
      function()
        require("neogit").open(popup ~= "status" and { popup } or nil)
      end,
      popup,
    }
  end,
})

local wk = require("which-key")

wk.register({
  name = "git",
  c = neogit.commit,
  b = neogit.branch,
  l = neogit.log,
  p = neogit.push,
  d = neogit.diff,
  r = neogit.rebase,
  S = neogit.stash,
  s = neogit.status,
  B = {
    function()
      local cursorline = vim.api.nvim_win_get_cursor(0)[1]
      local lstart, lend
      local mode = vim.api.nvim_get_mode().mode
      if mode == "v" or mode == "V" then
        local vstart = vim.fn.line("v") or cursorline
        lstart = math.min(vstart, cursorline)
        lend = math.max(vstart, cursorline)
      else
        lstart, lend = cursorline, cursorline
      end
      require("gitlinker").link({
        router = require("gitlinker.routers").github_browse,
        action = require("gitlinker.actions").system,
        lstart = lstart,
        lend = lend,
      })
    end,
    "open in browser",
  },
}, { mode = modes.non_editing, prefix = "<leader>g" })
