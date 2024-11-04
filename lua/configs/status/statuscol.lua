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

local _line_nrs = require("willothy.line-numbers")

local buf_sign_cache = {}

local function comfy_line_nrs(args)
  if args.relnum == 0 then
    return args.lnum
  end

  local buf, win = args.buf, args.win

  local version = vim.api.nvim_buf_get_changedtick(buf)
  local lnum = args.lnum - 1

  local entry = buf_sign_cache[buf]
  if entry and entry[1] == version and entry[2][lnum] then
    return entry[2][lnum].sign_text
  end

  local res = _line_nrs.hints(buf, win)

  if entry then
    entry[1] = version
    entry[2] = res
    buf_sign_cache[buf] = entry
  else
    buf_sign_cache[buf] = { version, res }
  end

  if not buf_sign_cache[buf][2][lnum] then
    return ""
  end

  return buf_sign_cache[buf][2][lnum].sign_text
end

local function lnumfunc(args)
  if args.virtnum < 0 then
    return " ──"
  end

  -- Calculate the actual buffer width, accounting for splits, number columns, and other padding
  local wrapped_lines = vim.api.nvim_win_call(0, function()
    local winid = vim.api.nvim_get_current_win()

    -- get the width of the buffer
    local winwidth = vim.api.nvim_win_get_width(winid)
    local numberwidth = vim.wo.number and vim.wo.numberwidth or 0
    local signwidth = vim.fn.exists("*sign_define") == 1
        and vim.fn.sign_getdefined()
        and 2
      or 0
    local foldwidth = vim.wo.foldcolumn or 0

    -- subtract the number of empty spaces in your statuscol. I have
    -- four extra spaces in mine, to enhance readability for me
    --
    --four extra spaces in mine, to enhance readability for mefour extra spaces in mine, to enhance readability for mefour extra spaces in mine, to enhance readability for me for mefour extra spaces in mine, to enhance readability for me
    local bufferwidth = winwidth - numberwidth - signwidth - foldwidth - 4

    -- fetch the line and calculate its display width
    local line = vim.fn.getline(vim.v.lnum)
    local line_length = vim.fn.strdisplaywidth(line)

    return math.floor(line_length / bufferwidth)
  end)

  if args.virtnum > 0 and (vim.wo.number or vim.wo.relativenumber) then
    if args.virtnum == wrapped_lines then
      return " └─"
    end
    return " │ " -- ├
  end

  -- return original_lnumfunc(args, ...)
  local res = comfy_line_nrs(args) or ""
  local len = string.len(res)
  if len < 3 then
    return string.rep(" ", 3 - len) .. res
  end
  return res
end

local statuscol = require("statuscol")

statuscol.setup({
  relculright = true,
  segments = {
    {
      sign = {
        -- name = { "GitSigns*" },
        namespace = { "gitsigns.*" },
        maxwidth = 1,
        minwidth = 1,
        colwidth = 1,
      },
      click = "v:lua.ScSa",
      condition = { is_normal_buf, is_normal_buf },
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
      text = { lnumfunc, " " },
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

local function update_all()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.bo[vim.api.nvim_win_get_buf(win)].buftype == "" then
      vim.wo[win].stc = "%!v:lua.require'statuscol'.get_statuscol_string()"
    end
  end
end

update_all()

vim.api.nvim_create_autocmd("User", {
  pattern = "ResessionLoadPost",
  callback = update_all,
})
