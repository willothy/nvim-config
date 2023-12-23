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
        namespace = { "gitsigns*" },
        maxwidth = 1,
        minwidth = 1,
        colwidth = 2,
      },
      click = "v:lua.ScSa",
      condition = { is_normal_buf },
    },
    {
      sign = {
        -- "Dap*", "Diagnostic*"
        name = { ".*" },
        -- "Dap*", "Diagnostic*"
        namespace = { "Diagnostic*", ".*" },
        maxwidth = 1,
        minwidth = 1,
        colwidth = 2,
      },
      click = "v:lua.ScSa",
      condition = { is_normal_buf, is_normal_buf },
    },
    {
      text = { builtin.lnumfunc, " " },
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
