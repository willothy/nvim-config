local KeyCode = {
  Move = vim.keycode("<LeftDrag>"),
  Resize = vim.keycode("<S-LeftDrag>"),
  LeftRelease = vim.keycode("<LeftRelease>"),
  RightRelease = vim.keycode("<RightRelease>"),
  MiddleRelease = vim.keycode("<MiddleRelease>"),
}

local FloatDrag = {}

function FloatDrag:step()
  local ok, info = pcall(vim.fn.getmousepos)
  if not ok then
    return
  end

  self.screencol = info.screencol
  self.screenrow = info.screenrow
  if not self.w then
    self.w = info.winid
    self.c = info.wincol
    self.r = info.winrow
  end
end

function FloatDrag:drag()
  FloatDrag:step()
  local cfg = vim.api.nvim_win_get_config(self.w)
  if cfg.relative == "" then
    return
  end

  cfg.col[false] = self.screencol - self.c - 1
  cfg.row[false] = self.screenrow - self.r - 1
  vim.api.nvim_win_set_config(self.w, cfg)
end

function FloatDrag:resize()
  FloatDrag:step()

  local cfg = vim.api.nvim_win_get_config(self.w)
  if cfg.relative == "" then
    return
  end

  cfg.width = math.max(self.screencol - cfg.col[false] - cfg.col[true], 1)
  cfg.height = math.max(self.screenrow - cfg.row[false] - cfg.row[true], 1)
  vim.api.nvim_win_set_config(self.w, cfg)
end

function FloatDrag:reset()
  self.w = nil
  self.screencol = nil
  self.screenrow = nil
end

function FloatDrag.setup(opts)
  opts = opts or {}
  if opts.resize then
    KeyCode.Resize = vim.keycode(opts.resize)
  end
  if opts.move then
    KeyCode.Move = vim.keycode(opts.move)
  end
  vim.on_key(function(k)
    if k == KeyCode.Move then
      FloatDrag:drag()
    elseif k == KeyCode.Resize then
      FloatDrag:resize()
    elseif
      k == KeyCode.LeftRelease
      or k == KeyCode.RightRelease
      or k == KeyCode.MiddleRelease
    then
      FloatDrag:reset()
    end
  end)
end

local Modenr = {}

function Modenr.setup()
  local api = vim.api
  local function mode_name()
    local mode = api.nvim_get_mode().mode
    local mode_names = {
      ["n"] = "Normal",
      ["i"] = "Insert",
      ["v"] = "Visual",
      ["V"] = "Visual",
      [""] = "Visual",
      ["s"] = "Select",
      ["S"] = "Select",
      ["R"] = "Replace",
      ["c"] = "Command",
      ["t"] = "Terminal",
      ["nt"] = "TerminalNormal",
    }
    return mode_names[mode] or "Normal"
  end

  local function update_mode()
    local mode = mode_name()
    local hl = api.nvim_get_hl(0, { name = mode .. "Mode", link = false })
    api.nvim_set_hl(0, "CursorLineNr", hl)
  end
  update_mode()

  local group = api.nvim_create_augroup("Modenr", { clear = true })
  api.nvim_create_autocmd("ModeChanged", {
    group = group,
    callback = update_mode,
  })
end

local noice = require("noice.util.hacks")
local prev_cursor

local function hide_cursor()
  prev_cursor = noice._guicursor
  noice._guicursor = nil
end

local function show_cursor()
  noice._guicursor = prev_cursor
  prev_cursor = nil
end

local Object = require("nui.object")

local Scrollbar = Object("NuiScrollbar")

local defaults = {
  winnr = 0,
  autohide = true,
  hl_group = {
    bar = "NoiceScrollbar",
    thumb = "NoiceScrollbarThumb",
  },
  ---@type _.NuiBorderPadding
  padding = {
    top = 0,
    right = 0,
    bottom = 0,
    left = 0,
  },
}

---@param opts? ScrollbarOptions
function Scrollbar:init(opts)
  self.opts = vim.tbl_deep_extend("force", defaults, opts or {})
  self.winnr = self.opts.winnr == 0 and vim.api.nvim_get_current_win()
    or self.opts.winnr
  self.visible = false
end

function Scrollbar:mount()
  self.autocmd_id = vim.api.nvim_create_autocmd(
    { "WinScrolled", "CursorMoved" },
    {
      callback = function()
        self:update()
      end,
    }
  )
  self:update()
end

function Scrollbar:unmount()
  if self.autocmd_id then
    vim.api.nvim_del_autocmd(self.autocmd_id)
    self.autocmd_id = nil
  end
  self:hide()
end

function Scrollbar:show()
  if not self.visible then
    self.visible = true
    self.bar = self:_open_win({ normal = self.opts.hl_group.bar })
    self.thumb = self:_open_win({ normal = self.opts.hl_group.thumb }, true)
  end
  self:update()
end

function Scrollbar:hide()
  if self.visible then
    self.visible = false
    local bar = self.bar
    if bar then
      pcall(vim.api.nvim_buf_delete, bar.bufnr, { force = true })
      pcall(vim.api.nvim_win_close, bar.winnr, true)
      self.bar = nil
    end

    local thumb = self.thumb
    if thumb then
      pcall(vim.api.nvim_buf_delete, thumb.bufnr, { force = true })
      pcall(vim.api.nvim_win_close, thumb.winnr, true)
      self.thumb = nil
    end
  end
end

local function win_buf_height(win)
  local buf = vim.api.nvim_win_get_buf(win)

  if not vim.wo[win].wrap then
    return vim.api.nvim_buf_line_count(buf)
  end

  local width = vim.api.nvim_win_get_width(win)

  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local height = 0
  for _, l in ipairs(lines) do
    height = height + math.max(1, (math.ceil(vim.fn.strwidth(l) / width)))
  end
  return height
end

function Scrollbar:update()
  if not vim.api.nvim_win_is_valid(self.winnr) then
    return self:hide()
  end

  local pos = vim.api.nvim_win_get_position(self.winnr)

  local dim = {
    row = pos[1] - self.opts.padding.top,
    col = pos[2] - self.opts.padding.left,
    width = vim.api.nvim_win_get_width(self.winnr)
      + self.opts.padding.left
      + self.opts.padding.right,
    height = vim.api.nvim_win_get_height(self.winnr)
      + self.opts.padding.top
      + self.opts.padding.bottom,
  }

  local buf_height = win_buf_height(self.winnr)

  if self.opts.autohide and dim.height >= buf_height then
    self:hide()
    return
  elseif not self.visible then
    self:show()
  end

  if
    not (
      vim.api.nvim_win_is_valid(self.bar.winnr)
      and vim.api.nvim_win_is_valid(self.thumb.winnr)
    )
  then
    self:hide()
    self:show()
  end

  local zindex = vim.api.nvim_win_get_config(self.winnr).zindex or 50

  local function win_apply_config(win, opts)
    opts =
      vim.tbl_deep_extend("force", vim.api.nvim_win_get_config(win), opts or {})
    vim.api.nvim_win_set_config(win, opts)
  end
  win_apply_config(self.bar.winnr, {
    height = dim.height,
    width = 1,
    col = dim.col + dim.width - 1,
    row = dim.row,
    zindex = zindex + 1,
  })

  local thumb_height = math.floor(dim.height * dim.height / buf_height + 0.5)
  thumb_height = math.max(1, thumb_height)

  local pct = vim.api.nvim_win_get_cursor(self.winnr)[1] / buf_height

  local thumb_offset = math.floor(pct * (dim.height - thumb_height) + 0.5)

  win_apply_config(self.thumb.winnr, {
    width = 1,
    height = thumb_height,
    row = dim.row + thumb_offset,
    col = dim.col + dim.width - 1, -- info.col was already added scrollbar offset.
    zindex = zindex + 2,
  })
end

function Scrollbar:_open_win(opts)
  local bufnr = vim.api.nvim_create_buf(false, true)
  local ret = {
    bufnr = bufnr,
    winnr = vim.api.nvim_open_win(bufnr, false, {
      relative = "editor",
      focusable = false,
      width = 1,
      height = 2,
      row = 0,
      col = 0,
      style = "minimal",
      noautocmd = true,
    }),
  }
  vim.api.nvim_win_set_option(
    ret.winnr,
    "winhighlight",
    "Normal:" .. opts.normal
  )
  return ret
end

local ScrollBarManager = {
  bars = {},
}

local list_wins = vim.api.nvim_list_wins

function ScrollBarManager.update()
  local old = vim.iter(ScrollBarManager.bars):fold({}, function(acc, winnr)
    acc[winnr] = true
    return acc
  end)
  vim
    .iter(list_wins())
    :filter(function(win)
      local winbuf = vim.api.nvim_win_get_buf(win)
      return vim.bo[winbuf].filetype ~= "noice"
        and vim.bo[winbuf].buflisted == true
        and vim.api.nvim_win_get_config(win).zindex == nil
    end)
    :each(function(win)
      if not ScrollBarManager.bars[win] then
        ScrollBarManager.bars[win] = Scrollbar:new(
          vim.tbl_deep_extend(
            "force",
            ScrollBarManager.options or {},
            { winnr = win }
          )
        )
        ScrollBarManager.bars[win]:mount()
      end
      old[win] = nil
    end)
  vim.iter(old):each(function(w)
    if ScrollBarManager.bars[w] then
      ScrollBarManager.bars[w]:unmount()
      ScrollBarManager.bars[w] = nil
    end
  end)
end

function ScrollBarManager.setup(opts)
  ScrollBarManager.options = opts or {}
  vim.api.nvim_create_autocmd(
    { "WinNew", "WinClosed", "TabNew", "TabClosed" },
    {
      callback = ScrollBarManager.update,
    }
  )
  ScrollBarManager.update()
end

return {
  setup = function()
    FloatDrag.setup()
    Modenr.setup()
    ScrollBarManager.setup({
      hl_group = {
        bar = "TabLineFill",
        thumb = "ScrollBar",
      },
    })
  end,
  show_cursor = show_cursor,
  hide_cursor = hide_cursor,
  scroll = ScrollBarManager,
}
