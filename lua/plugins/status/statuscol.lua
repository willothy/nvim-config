local icons = require("willothy.icons")

return {
  {
    "lewis6991/gitsigns.nvim",
    lazy = false,
    opts = {
      signs = {
        untracked = { text = icons.git.signs.bar },
        add = { text = icons.git.signs.bar },
        change = { text = icons.git.signs.bar },
        delete = { text = icons.git.signs.bar },
        topdelete = { text = icons.git.signs.bar },
        changedelete = { text = icons.git.signs.bar },
      },
      trouble = false,
      signcolumn = true,
    },
  },
  {
    "luukvbaal/statuscol.nvim",
    dependencies = {
      "lewis6991/gitsigns.nvim",
    },
    event = "VeryLazy",
    config = function()
      local blame = function(args)
        local line = args.mousepos.line
        require("blam").peek(line)
        return false
      end

      local builtin = require("statuscol.builtin")
      require("statuscol").setup({
        relculright = true,
        segments = {
          {
            sign = {
              name = { "GitSigns*" },
              maxwidth = 1,
              colwidth = 1,
            },
            click = "v:lua.ScSa",
          },
          {
            sign = {
              name = { ".*" },
              maxwidth = 1,
              colwidth = 2,
            },
            click = "v:lua.ScSa",
          },
          {
            text = { builtin.lnumfunc, " " },
            condition = { builtin.not_empty, true },
            click = "v:lua.ScLa",
          },
          {
            text = { builtin.foldfunc, " " },
            click = "v:lua.ScFa",
          },
        },
        clickhandlers = {
          Lnum = builtin.lnum_click,
          FoldClose = builtin.foldclose_click,
          FoldOpen = builtin.foldopen_click,
          FoldOther = false, --builtin.foldother_click,
          GitSignsTopdelete = blame,
          GitSignsUntracked = blame,
          GitSignsAdd = blame,
          GitSignsChange = blame,
          GitSignsChangedelete = blame,
          GitSignsDelete = blame,
        },
      })
    end,
  },
}
