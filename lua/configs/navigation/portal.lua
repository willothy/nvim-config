require("portal").setup({
  labels = { "w", "a", "s", "d" },
  escape = {
    ["<esc>"] = true,
    q = true,
    -- Close on any cursor moving event
    h = true,
    j = true,
    k = true,
    l = true,
    ["<left>"] = true,
    ["<right>"] = true,
    ["<up>"] = true,
    ["<down>"] = true,
  },
  window_options = {
    border = "rounded",
  },
})

local M = {}

function M.mkportal(title, items, callback, opts)
  opts = vim.tbl_deep_extend("keep", opts or {}, {
    max_results = 4,
  })
  local Content = require("portal.content")
  local Iterator = require("portal.iterator")
  local Portal = require("portal")

  local iter = Iterator:new(items)
  if opts.filter then
    iter = iter:filter(opts.filter)
  end
  if opts.map then
    iter = iter:map(opts.map)
  end
  iter = iter
    :map(function(v, _i)
      return Content:new({
        type = v.title or title,
        buffer = v.bufnr,
        cursor = { row = v.lnum, col = v.col },
        callback = callback,
      })
    end)
    :take(opts.max_results)

  local res = {
    source = iter,
    slots = opts.slots,
  }
  Portal.tunnel(res)
end

function M.diagnostics(opts)
  opts = vim.tbl_deep_extend("keep", opts or {}, {
    max_results = 4,
  })
  local diagnostics = vim.diagnostic.get(opts.buffer or nil)
  local Content = require("portal.content")
  local Iterator = require("portal.iterator")
  local Portal = require("portal")

  local iter = Iterator:new(diagnostics)
    :take(4)
    :map(function(v, _i)
      return Content:new({
        type = "diagnostics",
        buffer = v.bufnr,
        cursor = { row = v.lnum, col = 1 },
        extra = v.col,
        callback = function(content)
          local buf = content.buffer
          local cursor = content.cursor
          local win = vim.api.nvim_get_current_win()
          local bufnr = vim.api.nvim_win_get_buf(win)
          if buf ~= bufnr then
            vim.api.nvim_set_current_buf(buf)
          end
          vim.api.nvim_win_set_cursor(win, { cursor.row, content.extra })
        end,
      })
    end)
    :take(opts.max_results)
  local res = {
    source = iter,
    slots = nil,
  }
  Portal.tunnel(res)
end

function M.references(context)
  local params = vim.lsp.util.make_position_params()
  params.context = context or {
    includeDeclaration = true,
  }
  vim.lsp.buf_request(
    0,
    "textDocument/references",
    params,
    function(err, result)
      if err then
        vim.notify(err.message)
        return
      end
      if not result then
        vim.notify("no references found")
        return
      end
      local references = result
      M.mkportal("references", references, function(content)
        local buf = content.buffer
        local cursor = content.cursor
        local win = vim.api.nvim_get_current_win()
        local bufnr = vim.api.nvim_win_get_buf(win)
        if buf ~= bufnr then
          vim.api.nvim_set_current_buf(buf)
        end
        vim.api.nvim_win_set_cursor(win, { cursor.row + 1, cursor.col })
      end, {
        map = function(v)
          return {
            title = "references",
            bufnr = vim.uri_to_bufnr(v.uri),
            lnum = v.range.start.line,
            col = v.range.start.character,
          }
        end,
      })
    end
  )
end

return M
