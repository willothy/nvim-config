local autocmd = vim.api.nvim_create_autocmd

local group =
  vim.api.nvim_create_augroup("willothy.autocmds", { clear = true })

---The reason why the `FileChangedShell` event was triggered.
---Can be used in an autocommand to decide what to do and/or what
---to set v:fcs_choice to.
---
---Possible values:
---  deleted   file no longer exists
---  conflict  file contents, mode or timestamp was
---            changed and buffer is modified
---  changed   file contents has changed
---  mode      mode of file changed
---  time      only file timestamp changed
---
---@enum FileChangeReason
local FileChangeReason = {
  --- File no longer exists.
  Deleted = "deleted",
  --- File contents, mode or timestamp was changed and buffer is modified.
  Conflict = "conflict",
  --- File contents has changed.
  Changed = "changed",
  --- Mode of file changed.
  Mode = "mode",
  --- Only file timestamp changed.
  Time = "time",
}

---@enum FileChangeChoice
local FileChangeChoice = {
  --- Reload the buffer (does not work if
  --- the file was deleted).
  Reload = "reload",
  --- Reload the buffer and detect the
  --- values for options such as
  --- 'fileformat', 'fileencoding', 'binary'
  --- (does not work if the file was
  --- deleted).
  Edit = "edit",
  --- Ask the user what to do, as if there
  --- was no autocommand.  Except that when
  --- only the timestamp changed nothing
  --- will happen.
  Ask = "ask",
  --- Nothing, the autocommand should do
  --- everything that needs to be done.
  None = "",
}

---@alias FileChangeHandler fun(ev: vim.api.keyset.create_autocmd.callback_args): FileChangeChoice

---@type table<FileChangeReason, FileChangeHandler>
local FILE_CHANGE_HANDLERS = {
  [FileChangeReason.Deleted] = function(ev)
    vim.notify(
      "File deleted on disk. Buffer will be unloaded.",
      vim.log.levels.WARN,
      {}
    )
    return FileChangeChoice.None
  end,
  [FileChangeReason.Conflict] = function(ev)
    if vim.bo[ev.buf].modified then
      return FileChangeChoice.Ask
    else
      vim.notify(
        "File changed on disk, but the buffer is not modified. Reloading buffer.",
        vim.log.levels.WARN,
        {}
      )
      return FileChangeChoice.Reload
    end
  end,
  [FileChangeReason.Changed] = function(ev)
    return FileChangeChoice.Reload
  end,
  [FileChangeReason.Mode] = function(ev)
    vim.notify(
      "File mode changed on disk. This may affect how the file is accessed.",
      vim.log.levels.INFO,
      {}
    )
    return FileChangeChoice.Reload
  end,
  [FileChangeReason.Time] = function(ev)
    return FileChangeChoice.None
  end,
}

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
      -- if vim.bo[ev.buf].buftype ~= "" then
      --   vim.api.nvim_buf_call(ev.buf, require("mini.trailspace").unhighlight)
      -- end
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
    "FileChangedShell",
    callback = function(ev)
      vim.v.fcs_choice = FILE_CHANGE_HANDLERS[vim.v.fcs_reason](ev)
    end,
  },
  {
    "FileChangedShellPost",
    callback = function(ev)
      --
    end,
  },
  {
    { "BufLeave", "BufWinLeave" },
    callback = function(ev)
      if vim.bo[ev.buf].filetype == "lazy" then
        require("lazy.view").view:close({})
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
