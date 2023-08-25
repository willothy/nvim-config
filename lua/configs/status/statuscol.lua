local blame = function(args)
  local line = args.mousepos.line
  require("blam").peek(line)
  return false
end

local builtin = require("statuscol.builtin")
local ok, winborder = pcall(require, "winborder")
if ok then
  winborder = winborder.utils.statuscol
end

local function is_normal_buf(args)
  local buf = vim.api.nvim_win_get_buf(args.win)
  return vim.bo[buf].buftype == ""
end

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
  -- bt_ignore = {
  --   -- "nofile",
  -- },
  -- ft_ignore = {},
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

local filetypes = {
  harpoon = true,
}

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("stc", { clear = true }),
  callback = function()
    local win = vim.api.nvim_get_current_win()
    local buf = vim.api.nvim_win_get_buf(win)
    if
      filetypes[vim.bo[buf].filetype]
      and (vim.wo[win].number or vim.wo[win].relativenumber)
    then
      vim.wo[win].statuscolumn = "%!v:lua.StatusCol()"
    end
  end,
})
