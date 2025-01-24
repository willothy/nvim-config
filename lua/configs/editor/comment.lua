---@diagnostic disable-next-line: missing-fields
require("Comment").setup({
  pre_hook = function(ctx)
    -- if ctx.range.srow == ctx.range.erow then
    --   -- line
    -- else
    --   -- range
    -- end

    return require("ts-comments.comments").get(vim.bo.ft)
      or vim.bo.commentstring
  end,
  toggler = { -- Normal Mode
    line = "gcc",
    block = "gcb",
  },
  opleader = { -- Visual mode
    block = "gC",
    line = "gc",
  },
  ---@diagnostic disable-next-line: missing-fields
  extra = {
    eol = "gc$",
  },
})
