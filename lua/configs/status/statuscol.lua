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
        text = { ".*" },
        maxwidth = 1,
        minwidth = 1,
        colwidth = 2,
      },
      click = "v:lua.ScSa",
      condition = {
        is_normal_buf,
      },
    },
    {
      sign = {
        name = { "Dap*", "Diagnostic*", ".*" },
        maxwidth = 1,
        minwidth = 1,
        colwidth = 1,
      },
      click = "v:lua.ScSa",
      condition = {
        is_normal_buf,
        is_normal_buf,
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
  ft_ignore = {
    "Trouble",
  },
  clickhandlers = {
    FoldOther = false,
  },
})

vim.o.stc = "%!v:lua.StatusCol()"

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("willothy.stc", { clear = true }),
  callback = function()
    vim.o.statuscolumn = "%!v:lua.StatusCol()"
  end,
})

vim.api.nvim_create_autocmd("User", {
  pattern = "ResessionLoadPost",
  callback = function()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.bo[vim.api.nvim_win_get_buf(win)].buftype == "" then
        vim.wo[win].stc = "%!v:lua.StatusCol()"
      end
    end
  end,
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
