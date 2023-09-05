local M = {}

M.active = {}

local Line = require("nui.line")
local Text = require("nui.text")

function M.update(token, value)
  if value.kind == "begin" or not M.active[token] then
    M.active[token] = value
  elseif value.kind == "end" then
    M.active[token] = nil
  elseif M.active[token] then
    M.active[token] = vim.tbl_deep_extend("force", M.active[token], value)
  end
  M.render()
end

function M.render()
  if not M.buf then
    M.buf = vim.api.nvim_create_buf(false, true)
  end
  local i = 1
  local max = 0
  for _, progress in pairs(M.active) do
    local line = {}
    if progress.percentage then
      table.insert(
        line,
        Text(progress.percentage .. "%", "NoiceLspProgressTitle")
      )
      table.insert(line, Text(" ", "NoiceLspProgressTitle"))
    end
    if progress.message then
      table.insert(line, Text(progress.message, "NoiceLspProgressTitle"))
      table.insert(line, Text(" ", "NoiceLspProgressTitle"))
    end
    if progress.title then
      table.insert(line, Text(progress.title, "NoiceLspProgressTitle"))
      table.insert(line, Text(" ", "NoiceLspProgressTitle"))
    end
    line = Line(line)
    line:render(M.buf, M.ns, i)
    max = math.max(max, line:width())
    i = i + 1
  end
  if M.win and i == 1 then
    if vim.api.nvim_win_is_valid(M.win) then
      vim.api.nvim_win_close(M.win, true)
    end
    M.win = nil
  elseif M.win == nil and i > 1 then
    M.win = vim.api.nvim_open_win(M.buf, false, {
      style = "minimal",
      relative = "win",
      win = vim.api.nvim_get_current_win(),
      row = 0,
      col = 0,
      height = i,
      width = 100,
    })
  end
end

function M.setup()
  -- very wip
  -- M.ns = vim.api.nvim_create_namespace("NoiceLspProgresseeeee")
  --
  -- vim.api.nvim_create_autocmd("LspProgress", {
  --   group = vim.api.nvim_create_augroup("eeeee", { clear = true }),
  --   callback = function(ev)
  --     local data = ev.data.result
  --     M.update(data.token, data.value)
  --   end,
  -- })
end

return M
