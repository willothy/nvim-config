local indent = require("nvim-treesitter.indent")

local IndentScope = {
  cache = {},
}

local ns = vim.api.nvim_create_namespace("willothy_indentscope")

local function debounce(fn, timeout)
  local timer = vim.loop.new_timer()
  local running = false
  return function(...)
    if not running then
      fn(...)
      running = true
      timer:start(
        timeout,
        0,
        vim.schedule_wrap(function()
          running = false
        end)
      )
    end
  end
end

function IndentScope.update(buf)
  IndentScope.cache[buf] = {}
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  for i = 1, vim.api.nvim_buf_line_count(buf) do
    IndentScope.cache[buf][i] = indent.get_indent(i)
  end
end

function IndentScope.render(buf)
  local line_count = vim.api.nvim_buf_line_count(buf)
  if IndentScope.cache[buf] == nil or #IndentScope.cache[buf] < line_count then
    IndentScope.update(buf)
  end
  for linenr = 1, line_count do
    local chunk = { { "▏", "IndentScope" } }
    local indent_level = IndentScope.cache[buf][linenr]
    if indent_level >= vim.bo[buf].shiftwidth then
      local line_len =
        string.len(vim.api.nvim_buf_get_lines(buf, linenr - 1, linenr, true)[1])
      if line_len == 0 then
        local full_line = {}
        for _ = 1, indent_level, vim.bo[buf].shiftwidth do
          table.insert(full_line, chunk[1])
          table.insert(full_line, { " " })
        end
        vim.api.nvim_buf_set_extmark(buf, ns, linenr - 1, 0, {
          virt_text = full_line,
          virt_text_pos = "overlay",
          hl_mode = "blend",
          priority = 1,
        })
      else
        for col = 0, indent_level - vim.bo[buf].shiftwidth, vim.bo[buf].shiftwidth do
          if col <= line_len then
            vim.api.nvim_buf_set_extmark(buf, ns, linenr - 1, col, {
              virt_text = chunk,
              virt_text_pos = "overlay",
              hl_mode = "blend",
              priority = 1,
            })
          end
        end
      end
    end
  end
end

function IndentScope.setup()
  IndentScope.cache = {}
  local group =
    vim.api.nvim_create_augroup("willothy_indentscope", { clear = true })
  vim.api.nvim_create_autocmd("CursorMoved", {
    group = group,
    callback = debounce(function()
      local buf = vim.api.nvim_get_current_buf()
      IndentScope.render(buf)
    end, 500),
  })
  vim.api.nvim_create_autocmd(
    { "BufEnter", "TextChanged", "TextChangedI", "InsertLeave" },
    {
      group = group,
      callback = debounce(function()
        local buf = vim.api.nvim_get_current_buf()

        IndentScope.update(buf)
        IndentScope.render(buf)
      end, 500),
    }
  )
  vim.api.nvim_create_autocmd({ "BufNew", "BufLeave" }, {
    group = group,
    callback = debounce(function()
      for buf, _ in pairs(IndentScope.cache) do
        if not vim.api.nvim_buf_is_valid(buf) then
          IndentScope.cache[buf] = nil
        end
      end
      IndentScope.update(vim.api.nvim_get_current_buf())
    end, 2000),
  })
  IndentScope.update(vim.api.nvim_get_current_buf())
end

function IndentScope.enable()
  IndentScope.setup()
end

function IndentScope.disable()
  vim.iter(vim.api.nvim_list_bufs()):each(function(buf)
    vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  end)
  vim.api.nvim_create_augroup("willothy_indentscope", { clear = true })
end

return IndentScope
