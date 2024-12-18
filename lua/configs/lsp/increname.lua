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
    vim.notify(
      string.format(
        "%d instance%s in %d files",
        nrenames,
        nrenames == 1 and "" or "s",
        nfiles
      ),
      vim.log.levels.INFO,
      {
        title = "RENAMED",
      }
    )
  end,
})
