local icons = require("willothy.icons")
local bar = icons.git.signs.bar

return {
  {
    "lewis6991/gitsigns.nvim",
    event = "User ExtraLazy",
    opts = {
      signs = {
        untracked = { text = bar },
        add = { text = bar },
        change = { text = bar },
        delete = { text = bar },
        topdelete = { text = bar },
        changedelete = { text = bar },
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
    event = "User ExtraLazy",
    config = function()
      local blame = function(args)
        local line = args.mousepos.line
        require("blam").peek(line)
        return false
      end

      local builtin = require("statuscol.builtin")
      local ok, winborder = pcall(require, "winborder")
      if ok then winborder = winborder.utils.statuscol end

      local curwin = vim.api.nvim_get_current_win()
      vim.api.nvim_create_autocmd(
        { "WinEnter", "BufEnter", "WinNew", "BufNew", "BufAdd" },
        {
          callback = function() curwin = vim.api.nvim_get_current_win() end,
        }
      )

      require("statuscol").setup({
        relculright = true,
        segments = {
          {
            text = { " " },
            condition = { ok and winborder or false },
          },
          {
            sign = {
              name = { "GitSigns*" },
              maxwidth = 1,
              colwidth = 1,
              minwidth = 1,
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
            text = { builtin.lnumfunc },
            condition = {
              function(args)
                if not curwin then curwin = vim.api.nvim_get_current_win() end
                return args.relnum == 0 and args.win == curwin
              end,
            },
            hl = "CursorLineNr",
            click = "v:lua.ScLa",
          },
          {
            text = { builtin.lnumfunc, " " },
            condition = {
              function(args)
                if not curwin then curwin = vim.api.nvim_get_current_win() end
                return (args.relnum ~= 0) or (args.win ~= curwin)
              end,
              true,
            },
            click = "v:lua.ScLa",
          },
          {
            text = { builtin.foldfunc, " " },
            click = "v:lua.ScFa",
          },
        },
        bt_ignore = {
          "nofile",
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

      local tab = vim.api.nvim_get_current_tabpage()
      local wins = vim.api.nvim_tabpage_list_wins(tab)

      local stc = vim.api.nvim_win_get_option(curwin, "statuscolumn")
      for _, win in ipairs(wins) do
        if win ~= curwin then
          vim.api.nvim_win_set_option(win, "statuscolumn", stc)
        end
      end
    end,
  },
}
