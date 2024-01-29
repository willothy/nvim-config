require("inc_rename").setup({
  show_message = false,
  post_hook = function(opts)
    local nrenames, nfiles = unpack(vim
      .iter(opts)
      :map(function(_, renames)
        return vim.tbl_count(renames)
      end)
      :fold({ 0, 0 }, function(acc, val)
        acc[1] = acc[1] + val
        acc[2] = acc[2] + 1
        return acc
      end))
    local client = vim.lsp.get_clients({
      bunr = 0,
      method = "textDocument/rename",
    })[1]
    local handle = require("fidget.progress.handle").create({
      title = "RENAMED",
      message = string.format(
        "%d instance%s in %d files",
        nrenames,
        nrenames == 1 and "" or "s",
        nfiles
      ),
      lsp_client = {
        name = client and client.name or "inc-rename",
      },
    })
    vim.defer_fn(function()
      handle:finish()
    end, 350)
  end,
})
