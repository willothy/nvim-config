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

  vim.iter(changes):rev():each(function(change)
    vim.api.nvim_buf_set_lines(
      bufnr,
      change.start,
      change.final,
      false,
      change.formatted
    )
  end)
end

---@class Willothy.Buffer
local Buffer = {}

local handles = {}

function Buffer.new(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end
  if handles[bufnr] then
    return handles[bufnr]
  end

  local handle = { id = bufnr }

  setmetatable(handle, {
    __index = function(self, k)
      if vim.api["nvim_buf_" .. k] then
        return function(_, ...)
          if vim.api.nvim_buf_is_valid(self.id) then
            return vim.api["nvim_buf_" .. k](self.id, ...)
          end
        end
      end
    end,
    __newindex = function() end, -- Don't allow new keys
  })

  vim.api.nvim_buf_attach(bufnr, false, {
    on_detach = function()
      handles[bufnr] = nil
      return true
    end,
    -- prevent on_detach from being called on reload
    on_reload = function() end,
  })
  handles[bufnr] = handle

  return handle
end

function Buffer.current()
  return Buffer.new(vim.api.nvim_get_current_buf())
end

M.Buffer = Buffer

return M
