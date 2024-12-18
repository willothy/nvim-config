local autocmd = vim.api.nvim_create_autocmd

local group =
  vim.api.nvim_create_augroup("willothy.autocmds", { clear = true })

local autocmds = {
  {
    "LspAttach",
    callback = function(args)
      local bufnr = args.buf
      local client = vim.lsp.get_client_by_id(args.data.client_id)

      if not client then
        return
      end

      if client:supports_method("textDocument/foldingRange") then
        vim.api.nvim_set_option_value("foldexpr", "v:lua.vim.lsp.foldexpr()", {
          scope = "local",
        })
      end

      if client:supports_method("textDocument/documentHighlight") then
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

      if
        vim.lsp.inlay_hint
        and client:supports_method("textDocument/inlayHint")
      then
        vim.lsp.inlay_hint.enable(true, {
          bufnr = bufnr,
        })
      end
    end,
  },
  {
    "BufWritePost",
    callback = function(ev)
      if vim.bo[ev.buf].modifiable and vim.bo[ev.buf].buftype == "" then
        require("mini.trailspace").trim()
      end
    end,
  },
  {
    "FileType",
    callback = function(ev)
      if vim.bo[ev.buf].buftype ~= "" then
        vim.api.nvim_buf_call(ev.buf, require("mini.trailspace").unhighlight)
      end
      if vim.bo[ev.buf].buftype ~= "" then
        return
      end
      local parsers = require("nvim-treesitter.parsers")
      local ft = vim.bo[ev.buf].filetype
      local lang = parsers.ft_to_lang(ft)
      if not lang then
        vim.notify_once(
          "No language config for filetype '" .. ft .. "'",
          vim.log.levels.WARN,
          {}
        )
        return
      end
      if parsers.has_parser(lang) then
        vim.treesitter.start(ev.buf, lang)
      end
    end,
  },
  {
    { "BufRead", "BufNewFile" },
    pattern = { "*.rasi" },
    callback = function(ev)
      local buf = ev.buf
      vim.bo[buf].filetype = "rasi"
    end,
  },
  {
    "FileChangedShellPost",
    callback = function()
      vim.cmd("checktime")
    end,
  },
  {
    { "BufLeave", "BufWinLeave" },
    callback = function(ev)
      if vim.bo[ev.buf].filetype == "lazy" then
        require("lazy.view").view:close({})
      elseif vim.bo[ev.buf].filetype == "TelescopePrompt" then
        vim.api.nvim_exec2("silent! stopinsert!", {})
      end
    end,
  },
}

for _, v in ipairs(autocmds) do
  local event = v[1]
  v[1] = nil
  v.group = group
  autocmd(event, v)
end
