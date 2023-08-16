-- Generic scrollbar for windows
--
-- Heavily based on the scrollbar from folke/noice.nvim
--
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
    self.thumb = self:_open_win({ normal = self.opts.hl_group.thumb }, true)
  end
  self:update()
end

function Scrollbar:hide()
  if self.visible then
    self.visible = false
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
  if vim.api.nvim_win_is_valid(self.winnr) == false then
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

  if not vim.api.nvim_win_is_valid(self.thumb.winnr) then
    self:hide()
    self:show()
  end

  local zindex = vim.api.nvim_win_get_config(self.winnr).zindex or 50

  local function win_apply_config(win, opts)
    opts =
      vim.tbl_deep_extend("force", vim.api.nvim_win_get_config(win), opts or {})
    vim.api.nvim_win_set_config(win, opts)
  end

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

function ScrollBarManager.update()
  local old = vim.iter(ScrollBarManager.bars):fold({}, function(acc, winnr)
    acc[winnr] = true
    return acc
  end)
  vim
    .iter(vim.api.nvim_tabpage_list_wins(0))
    :filter(function(win)
      local winbuf = vim.api.nvim_win_get_buf(win)
      return vim.bo[winbuf].filetype ~= "noice"
        and vim.bo[winbuf].buftype == ""
        and vim.api.nvim_win_get_config(win).zindex == nil
    end)
    :each(function(win)
      if not ScrollBarManager.bars[win] then
        ScrollBarManager.bars[win] = Scrollbar:new(
          vim.tbl_deep_extend(
            "force",
            ScrollBarManager.options,
            { winnr = win }
          )
        )
        ScrollBarManager.bars[win]:mount()
      end
      old[win] = nil
      ScrollBarManager.bars[win]:update()
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
  vim.api.nvim_create_autocmd({
    "WinNew",
    "WinClosed",
    "TabNew",
    "TabClosed",
    "TabEnter",
    "TermEnter",
  }, {
    callback = ScrollBarManager.update,
  })
  ScrollBarManager.update()
end

return ScrollBarManager
