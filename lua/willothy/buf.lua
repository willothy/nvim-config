local M = {}

---Use stylua to format embedded lua code blocks in markdown files.
---@param bufnr integer?
function M.format_embedded_lua(bufnr)
  local query = [[
    (fenced_code_block
      (info_string
        (language) @lang (#eq? @lang "lua")
      )
      (code_fence_content) @lua
    )
  ]]
  local embedded_lua = vim.treesitter.query.parse("markdown", query)

  bufnr = bufnr or vim.api.nvim_get_current_buf()

  if vim.bo[bufnr].filetype ~= "markdown" then
    return
  end

  local parser = vim.treesitter.get_parser(bufnr, "markdown", {})
  if not parser then
    return
  end
  local tree = parser:parse()[1]
  local root = tree and tree:root()
  if not root then
    return
  end

  local changes = vim
    .iter(embedded_lua:iter_captures(root, bufnr, 0, -1))
    :filter(function(id)
      return embedded_lua.captures[id] == "lua"
    end)
    :map(function(_, node)
      local range = { node:range() }
      local indent = string.rep(" ", range[2])
      local node_text = vim.treesitter.get_node_text(node, bufnr)

      local res = vim
        .system({ "stylua", "-" }, {
          text = true,
          stdin = node_text,
        })
        :wait()
      if res.code ~= 0 then
        return
      end
      local formatted = vim.split(res.stdout, "\n")

      for idx, line in ipairs(formatted) do
        formatted[idx] = indent .. line
      end

      return {
        start = range[1],
        final = range[3],
        formatted = formatted,
      }
    end)
    :totable()

  for i = #changes, 1, -1 do
    local change = changes[i]
    vim.api.nvim_buf_set_lines(
      bufnr,
      change.start,
      change.final,
      false,
      change.formatted
    )
  end
end

return M
