local builtin = require("statuscol.builtin")
local ffi = require("statuscol.ffidef")

local C = ffi.C

ffi.cdef([[
  typedef int32_t linenr_T;
  typedef int colnr_T;
  typedef struct {
    linenr_T lnum;
    colnr_T col;
    colnr_T coladd;
  } pos_T;
  void opFoldRange(pos_T start, pos_T end, bool open, bool recursive, bool ignore);
]])

-- typedef struct {
--   linenr_T lnum;        ///< line number
--   colnr_T col;          ///< column number
--   colnr_T coladd;
-- } pos_T;

local fold_info = C.fold_info
local find_window_by_handle = C.find_window_by_handle
local op_fold_range = C.opFoldRange

local function is_normal_buf(args)
  local buf = vim.api.nvim_win_get_buf(args.win)

  return vim.bo[buf].buftype == ""
end

-- cache the FFI pos_T structs bc we only need two
local start
local end_
local err

local function do_fold(win, line, open)
  err = ffi.new("Error")
  local wp = find_window_by_handle(win, err)
  if not wp then
    return
  end
  local fold = fold_info(wp, line)

  -- if fold_info_T.level == 0 "all other fields are N/A"
  if fold.level == 0 then
    return
  end

  if not start then
    start = ffi.new("pos_T")
    start.col = 0
    start.coladd = 0
    end_ = ffi.new("pos_T")
    end_.col = 0
    end_.coladd = 0
  end
  start.lnum = fold.start
  end_.lnum = fold.start + fold.lines

  op_fold_range(start, end_, open, false, false)
end

local function open_fold(win, line)
  do_fold(win, line, true)
end

local function close_fold(win, line)
  do_fold(win, line, false)
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
        namespace = { "diagnostic*" },
        maxwidth = 1,
        minwidth = 1,
        colwidth = 2,
      },
      click = "v:lua.ScSa",
      condition = { is_normal_buf, is_normal_buf },
    },
    {
      sign = {
        namespace = { "comfy-.*" },
        maxwidth = 1,
        minwidth = 1,
        colwidth = 3,
      },
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
    "trouble",
    "noice",
  },
  clickhandlers = {
    FoldOther = false,
    FoldOpen = function(args)
      ---@type vim.fn.getmousepos.ret
      local mouse = args.mousepos
      do_fold(mouse.winid, mouse.line, false)
    end,
    FoldClose = function(args)
      ---@type vim.fn.getmousepos.ret
      local mouse = args.mousepos
      do_fold(mouse.winid, mouse.line, true)
    end,
  },
})

-- vim.api.nvim_create_autocmd("User", {
--   pattern = "ResessionLoadPost",
--   callback = function()
--     for _, win in ipairs(vim.api.nvim_list_wins()) do
--       if vim.bo[vim.api.nvim_win_get_buf(win)].buftype == "" then
--         vim.wo[win].stc = "%!v:lua.StatusCol()"
--       end
--     end
--   end,
-- })
