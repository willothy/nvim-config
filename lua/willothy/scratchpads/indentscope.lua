local indent = require("nvim-treesitter.indent")

local cache = {
  bufs = {},
}

local ns = vim.api.nvim_create_namespace("willothy_indentscope")

local function update(buf)
  cache.bufs[buf] = {}
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  for i = 1, vim.api.nvim_buf_line_count(buf) do
    cache.bufs[buf][i] = indent.get_indent(i)
  end
end

local function render(buf)
  if
    cache.bufs[buf] == nil
    or #cache.bufs[buf] ~= vim.api.nvim_buf_line_count(buf)
  then
    update(buf)
  end
  for linenr = 1, vim.api.nvim_buf_line_count(buf) do
    local chunk = { { "▏", "Comment" } }
    local indent_level = cache.bufs[buf][linenr]
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

local function setup()
  local group =
    vim.api.nvim_create_augroup("willothy_indentscope", { clear = true })
  vim.api.nvim_create_autocmd("CursorMoved", {
    group = group,
    callback = function()
      local buf = vim.api.nvim_get_current_buf()
      render(buf)
    end,
  })
  vim.api.nvim_create_autocmd({ "BufEnter", "TextChanged" }, {
    group = group,
    callback = function()
      local buf = vim.api.nvim_get_current_buf()

      update(buf)
      render(buf)
    end,
  })
end

return {
  enable = setup,
  disable = function()
    vim.api.nvim_create_augroup("willothy_indentscope", { clear = true })
  end,
  setup = setup,
}
