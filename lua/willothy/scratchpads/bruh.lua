local rx = require("leptos")
local a = willothy.async

local test = rx.create_signal("ls")

rx.create_effect(a.void(function()
  local v = a.system({ test.get() }, { text = true }, nil)
  vim.notify(v.stdout)
end))

_G.command = test
