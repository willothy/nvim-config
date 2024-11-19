local buf = vim.api.nvim_create_buf(false, true)

vim.bo[buf].buftype = "prompt"

vim.treesitter.start(buf, "lua")

local function push_text(text)
  if type(text) == "string" then
    vim.api.nvim_buf_set_lines(buf, -1, -1, false, { text })
    return
  end

  vim.api.nvim_buf_set_lines(buf, -1, -1, false, text)
end

local function try(ok, ...)
  return ok, { ... }
end

local sandbox_env = setmetatable({
  print = push_text,
}, {
  __index = _G,
})

vim.fn.prompt_setcallback(buf, function(code)
  local fn, err = loadstring(code)
  if err ~= nil or fn == nil then
    push_text("Error: " .. (err or "unknown"))
    return
  end
  debug.setfenv(fn, sandbox_env)
  local ok, res = try(pcall(fn))
  if ok then
    for _, val in ipairs(res) do
      push_text(vim.split(vim.inspect(val), "\n", { trimempty = true }))
    end
  else
    push_text("Error: " .. res)
  end
end)
vim.fn.prompt_setprompt(buf, ":lua ")

local win = vim.api.nvim_open_win(buf, true, {
  split = "below",
})
