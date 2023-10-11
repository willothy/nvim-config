local a = require("micro-async")

local F = require("flatten.guest")

F.task = a.void(function()
  local ok, res = F.exec_on_host("print('test'); return 5", false)
  vim.print(res)
end)()
