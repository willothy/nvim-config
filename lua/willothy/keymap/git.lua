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
      require("gitlinker").link({
        action = require("gitlinker.actions").system,
      })
    end,
    "open in browser",
  },
}, { mode = modes.non_editing, prefix = "<leader>g" })
