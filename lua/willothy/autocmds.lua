local autocmd = vim.api.nvim_create_autocmd

local group =
  vim.api.nvim_create_augroup("willothy.autocmds", { clear = true })

autocmd("LspAttach", {
  callback = function(args)
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)

    if not client then
      return
    end

    if client.supports_method("textDocument/documentHighlight") then
      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        buffer = bufnr,
        group = group,
        callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        buffer = bufnr,
        group = group,
        callback = vim.lsp.buf.clear_references,
      })
    end

    if client.supports_method("textDocument/inlayHint") then
      vim.lsp.inlay_hint(bufnr, true)
    end

    require("ufo").attach(bufnr)
  end,
})

autocmd("BufWritePost", {
  group = group,
  callback = function()
    require("mini.trailspace").trim()
  end,
})

autocmd("FileType", {
  group = group,
  callback = function(ev)
    if vim.bo[ev.buf].buftype ~= "" then
      vim.api.nvim_buf_call(ev.buf, require("mini.trailspace").unhighlight)
    end
  end,
})

autocmd("TermResponse", {
  group = group,
  callback = function()
    vim.cmd("checktime")
  end,
})

autocmd("TermOpen", {
  group = group,
  callback = function(args)
    local buf = args.buf
    vim.bo[buf].filetype = "terminal"
  end,
})

autocmd("BufWinLeave", {
  callback = function(ev)
    if vim.bo[ev.buf].filetype == "TelescopePrompt" then
      vim.cmd("silent! stopinsert!")
    end
  end,
})
