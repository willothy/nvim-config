local builtin = require("statuscol.builtin")

local function is_normal_buf(args)
  local buf = vim.api.nvim_win_get_buf(args.win)
  return vim.bo[buf].buftype == ""
end

require("statuscol").setup({
  relculright = true,
  segments = {
    {
      sign = {
        name = { "GitSigns*" },
        maxwidth = 1,
        colwidth = 1,
        minwidth = 1,
      },
      click = "v:lua.ScSa",
      condition = {
        is_normal_buf,
      },
    },
    {
      sign = {
        name = { ".*" },
        maxwidth = 1,
        colwidth = 2,
      },
      click = "v:lua.ScSa",
      condition = {
        is_normal_buf,
      },
    },
    {
      text = { builtin.lnumfunc },
      condition = {
        function(args)
          return args.relnum == 0
            and args.win == vim.api.nvim_get_current_win()
        end,
      },
      hl = "CurrentMode",
      click = "v:lua.ScLa",
    },
    {
      text = { builtin.lnumfunc, " " },
      condition = {
        function(args)
          return (args.relnum ~= 0)
            or (args.win ~= vim.api.nvim_get_current_win())
        end,
        is_normal_buf,
      },
      click = "v:lua.ScLa",
    },
    {
      text = { builtin.foldfunc, " " },
      click = "v:lua.ScFa",
      condition = {
        is_normal_buf,
        true,
      },
    },
  },
  clickhandlers = {
    FoldOther = false,
  },
})

vim
  .iter(vim.api.nvim_list_wins())
  :filter(function(w)
    local buf = vim.api.nvim_win_get_buf(w)
    return vim.bo[buf].buftype == ""
  end)
  :each(function(win)
    vim.wo[win].stc = "%!v:lua.StatusCol()"
  end)
